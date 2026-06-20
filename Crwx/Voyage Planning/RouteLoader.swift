//
//  RouteLoader.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import Foundation
import SwiftData
import CoreLocation
import FoundationSalt
import os

@ModelActor
final actor RouteLoader {
    func harbourViewModel(from start: PersistentIdentifier, to end: PersistentIdentifier) async throws -> HarbourViewModel {
        guard let start = self[start, as: Waypoint.self],
              let end = self[end, as: Waypoint.self]
        else { throw E.BadId }
        return await .init(start: start, destination: end, routes: self)
    }
    
    /// This will return the shortest route between the two if a route can be found.
    ///
    /// It will potentially stitch together two routes, but won't look for a third route in between.  If it were to do that, it would want to know which waypoints were likely candidates for stitching together - like offshore hub to offshore hub.
    func route(from start: PersistentIdentifier, to end: PersistentIdentifier) async throws -> RouteSnippet? {
        guard let start = self[start, as: Waypoint.self],
              let end = self[end, as: Waypoint.self]
        else { throw E.BadId }
        try load()
        
        // 1. If there is a route directly between the two, return the shortest
        let lhs = allWaypoints(for: start.id)
        if lhs.contains(end.id) {
            guard let route = try shortest(routes(containing: start.id, and: end.id), start: start.id, end: end.id)
            else { throw E.RouteExpected }
            return route
        }
        
        // 2. If there are routes where the two intersect
        let rhs = allWaypoints(for: end.id)
        let common = lhs.intersection(rhs)
        
        // 3. If no intersection with one level of separation, return nil
        guard !common.isEmpty else { return nil }
        
        // 4. Get the shortest route via each common way point
        if let points = try common.map({
            try shortest(from: start.id, to: end.id, via: $0)
        }).sorted().first?.points {
            return await .init(points, generated: true)
        }
        return nil
    }
    private func routeId<P>(for points: [P]) -> UUID? where P: Identifiable, P.ID == UUID {
        let points = points.map { $0.id }
        return route_to_waypoints.first { (key, value) in
            value == points
        }?.key
    }
    
    
    // MARK: Saving Edits
    func saveRoute(id: UUID?, points: [WaypointSnippet], isReviewed: Bool) async throws {
        guard points.count > 1 else { return }
        try load()
        
        // 1. See if we need to insert any new waypoints
        for point in points {
            if waypoint_lookup[point.id] == nil {
                let new = await Waypoint(
                    id: point.id,
                    source: "",
                    latitude: point.latitude,
                    longitude: point.longitude,
                    name: "",
                    _symbol: nil,
                    created: .now,
                    imported: nil,
                    stamp: .stamp(latitude: point.latitude, longitude: point.longitude)
                )
                modelContext.insert(new)
                waypoint_lookup[point.id] = new
            }
        }
        try modelContext.save()
        
        // 2. See if we're dealing with new or existing route
        let route: Route
        if let existing = Route.find(id, in: modelContext) {
            route = existing
        } else {
            route = Route(id: id ?? .init(), name: "", length: 0, created: .now, imported: nil, endpointNames: "", endpointIds: "", endpointStamps: "")
            modelContext.insert(route)
            try modelContext.save()
        }
        
        // 3. Unrelate any removed waypoints
        let existingIds = route.waypointIds
        let newIds = points.map { $0.id }
        for id in existingIds.set.subtracting(newIds) {
            guard let wp = waypoint_lookup[id]
            else { throw E.WaypointExpected }
            wp.remove(child: route, from: \.routes)
            route.remove(child: wp, from: \.waypointsUsed)
        }
        
        // 4. Relate any new waypoints
        for id in newIds.set.subtracting(existingIds) {
            guard let wp = waypoint_lookup[id]
            else { throw E.WaypointExpected }
            wp.add(child: route, to: \.routes)
            route.add(child: wp, to: \.waypointsUsed)
        }
        
        // 5. Set the points, distance, stamps, and name
        route.waypointIds = newIds
        route.length = points.totalDistance.converted(to: .nauticalMiles).value
        try route.restamp(in: modelContext)
        route.reviewed = isReviewed ? .now : nil
        
        try modelContext.save()
    }
    
    
    // MARK: Waypoint Deduplication
    func allRoutes() async throws -> [RouteSnippet] {
        try load()
        return try route_to_waypoints.map { (key, value) in
            try .init(value.map {
                guard let wp = waypoint_lookup[$0]
                else { throw E.WaypointExpected }
                return .init(wp)
            }, generated: false, sourceId: key)
        }
    }
    func allLegs() async throws -> Set<RouteSnippet> {
        try await allRoutes().flatMap {
            $0.legs
        }.set
    }
    /// Using route snippet just to provide an identifiable collection of waypoints, though the order doesn't matter and we're not going to draw them as combined
    ///
    /// Threshold is in feet
    func deduplicationCandidates(threshold: Double = 250) async throws -> [RouteSnippet] {
        try load()
        let feetPerDegreeLongitude = 43.0 * 6_072
        let threshold = threshold / feetPerDegreeLongitude // feet
        // first lets see if any are close enough walking west to east
        let allWaypoints: [WaypointSnippet] = waypoint_lookup.values.filter {
            $0.importSource == .rosepoint
        }.map { .init($0) }.sorted(by: \.longitude)
        var reader = allWaypoints.reader
        var verticalStrips = [Set<WaypointSnippet>]()
        var currentPoint = reader.read()
        var currentBand: Set<WaypointSnippet> = [currentPoint]
        while !reader.didReachEnd {
            let nextPoint = reader.read()
            if (nextPoint.longitude - currentPoint.longitude).magnitude < threshold {
                currentBand.insert(nextPoint)
            }
            else {
                if currentBand.count > 1 {
                    verticalStrips.append(currentBand)
                }
                currentBand = [nextPoint]
            }
            currentPoint = nextPoint
        }
        if currentBand.count > 1 {
            verticalStrips.append(currentBand)
        }
        // then let's walk south to north through each band
        var candidates = [RouteSnippet]()
        for band in verticalStrips {
            var reader = band.sorted(by: \.latitude).reader
            var currentPoint = reader.read()
            var currentCluster: Set<WaypointSnippet> = [currentPoint]
            while !reader.didReachEnd {
                let nextPoint = reader.read()
                if (nextPoint.latitude - currentPoint.latitude).magnitude < threshold {
                    currentCluster.insert(nextPoint)
                }
                else {
                    if currentCluster.count > 1 {
                        candidates.append(.init(currentCluster.sorted(by: \.latitude), generated: true))
                    }
                    currentCluster = [nextPoint]
                }
                currentPoint = nextPoint
            }
            if currentCluster.count > 1 {
                candidates.append(.init(currentCluster.sorted(by: \.latitude), generated: true))
            }
        }
        return candidates
    }
    func fuse(waypoints: [UUID], to point: CLLocationCoordinate2D) async throws {
        try load()
        
        // 1. Get those waypoints
        var waypoints = try waypoints.map {
            guard let match = waypoint_lookup[$0]
            else { throw E.WaypointExpected }
            return match
        }
        
        // 2. Decide which to keep
        .sorted(by: { lhs, rhs in
            // keep the one used by more routes
            let lhc = lhs.routes?.count ?? 0
            let rhc = rhs.routes?.count ?? 0
            if lhc != rhc {
                return lhc > rhc
            }
            // keep the one with a symbol
            if lhs.symbol == nil, rhs.symbol != nil {
                return false
            } else if lhs.symbol != nil, rhs.symbol == nil {
                return true
            }
            // keep the one with a name
            if lhs.name.isEmpty, !rhs.name.isEmpty {
                return false
            } else if !lhs.name.isEmpty, rhs.name.isEmpty {
                return true
            }
            // keep the one with a colour
            if lhs.symbol?.colour == nil, rhs.symbol?.colour != nil {
                return false
            } else if lhs.symbol?.colour != nil, rhs.symbol?.colour == nil {
                return true
            }
            return lhs.name < rhs.name
        })
        guard waypoints.count >= 2 else { throw E.WaypointExpected }
        let keeper = waypoints.removeFirst()
        
        // 3. Move all the best information into the one we're going to keep
        if keeper.name.isEmpty {
            keeper.name = waypoints.first(where: {
                !$0.name.isEmpty
            })?.name ?? ""
        }
        if keeper.symbol?.colour == nil {
            keeper.symbol = waypoints.first(where: {
                $0.symbol?.colour != nil
            })?.symbol ?? keeper.symbol
        } else if keeper.symbol == nil {
            keeper.symbol = waypoints.first(where: {
                $0.symbol != nil
            })?.symbol
        }
        keeper.latitude = point.latitude
        keeper.longitude = point.longitude
        
        // 4. Find all routes that use waypoints we're getting rid of
        var routeIds: Set<UUID> = []
        for wp in waypoints {
            routeIds.insert(waypoint_to_routes[wp.id] ?? [])
        }
        
        // 5. Remove or replace the waypoints in those routes
        let deprecatedIds = waypoints.map { $0.id }.set
        for routeId in routeIds {
            guard var waypointIds = route_to_waypoints[routeId]
            else { throw E.RouteExpected }
            guard let route = Route.find(routeId, in: modelContext)
            else { throw E.RouteExpected }
            if waypointIds.contains(keeper.id) {
                waypointIds.removeAll(where: {
                    deprecatedIds.contains($0)
                })
            } else {
                waypointIds = waypointIds.map {
                    if deprecatedIds.contains($0) {
                        return keeper.id
                    } else {
                        return $0
                    }
                }
                var lastId: UUID?
                waypointIds = waypointIds.reduce(into: [], { partialResult, id in
                    if id != lastId {
                        partialResult.append(id)
                        lastId = id
                    }
                })
                route.add(child: keeper, to: \.waypointsUsed)
                keeper.add(child: route, to: \.routes)
            }
            route.waypointIds = waypointIds
        }
        
        // 6. Delete the unused waypoints
        for waypoint in waypoints {
            await logger.warning("Deleting \(describing(waypoint))")
            modelContext.delete(waypoint)
        }
        
        try modelContext.save()
        isLoaded = false
        
    }
    private var isLoaded = false
    private var waypoint_to_routes: [UUID: Set<UUID>] = [:]
    private var route_to_waypoints: [UUID: [UUID]] = [:] // must be ordered
    private var waypoint_lookup: [UUID: Waypoint] = [:] // used to materialise route waypoints
}


// MARK: Helper Methods
extension RouteLoader {
    private func allWaypoints(for harbour: UUID) -> Set<UUID> {
        waypoint_to_routes[harbour]?.flatMap {
            route_to_waypoints[$0] ?? []
        }.set ?? []
    }
    private func routes(containing start: UUID, and end: UUID) -> [UUID] {
        var matches = [UUID]()
        for (key, value) in route_to_waypoints {
            if value.contains(start) && value.contains(end) {
                matches.append(key)
            }
        }
        return matches
    }
    private func routes(from start: UUID, to end: UUID) throws -> [RouteSnippet] {
        
        // 1. Get all routes that contain both waypoints
        let prospects = try routes(containing: start, and: end).map {
            guard let match = route_to_waypoints[$0] else { throw E.RouteExpected }
            return match
        }
            
        // 2. Trim all points that are not start or end, and order start to end
        .map {
            try $0.trimmed(start: start, end: end)
        }
        
        // 3. Convert to waypoints
        let waypoints: [[WaypointSnippet]] = try prospects.map {
            try $0.map {
                guard let match = waypoint_lookup[$0] else { throw E.WaypointExpected }
                return .init(match)
            }
        }
        
        // 3. Convert to route snippets
        return waypoints.map {
            .init($0, generated: false, sourceId: routeId(for: $0))
        }

    }
    private func shortest(from start: UUID, to end: UUID, via: UUID) throws -> RouteSnippet {
        guard let inbound = try routes(from: start, to: via).sorted().first,
              let continuation = try routes(from: via, to: end).sorted().first
        else { throw E.RouteExpected }
        return try inbound.appending(continuation)
    }
    private func shortest(_ routes: [UUID], start: UUID, end: UUID) throws -> RouteSnippet? {
        try routes.compactMap {
            try build(route: $0, start: start, end: end)
        }.sorted(by: \.distance).first
    }
    private func build(route: UUID, start: UUID, end: UUID) throws -> RouteSnippet? {
        guard let ids = route_to_waypoints[route]
        else { return nil }
        let trimmed = try ids.trimmed(start: start, end: end)
        return .init(trimmed.compactMap {
            waypoint_lookup[$0]
        }.map {
            .init($0)
        }, generated: trimmed != ids, sourceId: trimmed == ids ? route : nil)
    }
}
extension [UUID] {
    func trimmed(start: UUID, end: UUID) throws -> [UUID] {
        let trimmed = self.trimmed {
            $0 != start && $0 != end
        }
        guard trimmed.count > 1 else { throw RouteLoader.E.WaypointExpected }
        if trimmed.first == start {
            guard trimmed.last == end else { throw RouteLoader.E.WaypointExpected }
            return trimmed
        } else if trimmed.first == end {
            guard trimmed.last == start else { throw RouteLoader.E.WaypointExpected }
            return trimmed.reversed()
        } else {
            throw RouteLoader.E.WaypointExpected
        }
    }
}


// MARK: Load Caches
extension RouteLoader {
    private func load() throws {
        guard !isLoaded else { return }
        let waypoints = try modelContext.fetch(Waypoint.self)
        waypoint_to_routes = waypoints.reduce(into: [:], { partialResult, waypoint in
            partialResult[waypoint.id] = waypoint.routes?.map {
                $0.id
            }.set ?? []
        })
        waypoint_lookup = waypoints.reduce(into: [:], { partialResult, waypoint in
            partialResult[waypoint.id] = waypoint
        })
        let routes = try modelContext.fetch(Route.self)
        route_to_waypoints = routes.reduce(into: [:], { partialResult, route in
            partialResult[route.id] = route.waypointIds
        })
        isLoaded = true
    }
    
    enum E: Error {
        case BadId
        case RouteExpected
        case WaypointExpected
        case InvalidContinuation
    }
}


// MARK: Endpoints
extension RouteLoader {
    /// Given a waypoint, return all waypoints that are endpoints connected via this waypoint
    func endpoints(off: UUID) async throws -> [PersistentIdentifier] {
        try load()
        let routes = try waypoint_to_routes[off]?.map {
            guard let route = route_to_waypoints[$0]
            else { throw E.RouteExpected }
            return route
        }
        var endpoints: Set<UUID> = []
        for route in routes ?? [] {
            if let first = route.first {
                endpoints.insert(first)
            }
            if route.count > 1,
               let last = route.last
            {
                endpoints.insert(last)
            }
        }
        return try endpoints.map {
            guard let wp = waypoint_lookup[$0]
            else { throw E.WaypointExpected }
            return wp.persistentModelID
        }
    }
    func existingRoute(_ endpoints: Set<UUID>) async throws -> RouteSnippet? {
        try load()
        guard let first = endpoints.first,
              endpoints.count == 2
        else { return nil }
        if let matches = waypoint_to_routes[first] {
            for route_id in matches {
                guard let route = route_to_waypoints[route_id]
                else { throw E.RouteExpected }
                if !route.ends.intersection(endpoints).isEmpty,
                   endpoints.intersection(route).count == 2
                {
                    let waypoints = try route.map {
                        guard let wp = waypoint_lookup[$0]
                        else { throw E.WaypointExpected }
                        return wp
                    }
                    return .init(waypoints.map { .init($0) }, generated: false, sourceId: routeId(for: waypoints))
                }
            }
        }
        return nil
    }
    /// Find all routes that start or end on one of these waypoints and return the set of legs from these combined routes
    func legs(endpoints: Set<UUID>) async throws -> Set<RouteSnippet> {
        try load()
        
        // 1. Get all routes that start and stop on these endpoints
        let routes: [[UUID]] = try endpoints.flatMap { endpoint_id in
            if let matches = waypoint_to_routes[endpoint_id] {
                return try matches.compactMap { route_id in
                    guard let route = route_to_waypoints[route_id]
                    else { throw E.RouteExpected }
                    if route.ends.contains(endpoint_id) {
                        return route
                    }
                    return nil
                }
            }
            return []
        }
        
        // 2. Convert to waypoint snippets
        let snippets: [[WaypointSnippet]] = try routes.map {
            try $0.map {
                guard let wp = waypoint_lookup[$0]
                else { throw E.WaypointExpected }
                return .init(wp)
            }
        }
        
        // 3. Convert to route snippets
        let routeSnippets: [RouteSnippet] = snippets.map {
            .init($0, generated: false, sourceId: routeId(for: $0))
        }
        
        // 4. Reduce to legs
        return routeSnippets.flatMap {
            $0.legs
        }.set
    }
}
