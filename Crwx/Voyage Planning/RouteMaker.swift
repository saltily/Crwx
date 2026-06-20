//
//  RouteMaker.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/17/25.
//

import Foundation
import SwiftData
import CoreLocation
import MapKit
import FoundationSalt

@Observable
@MainActor
final class RouteMaker {
    let id: UUID?
    var points: [WaypointSnippet]
    var selectedIndex: Int?
    private var isUncommited = false
    let allWaypoints: [WaypointSnippet]
    let context: ModelContext
    init(modelContext: ModelContext, snippet: RouteSnippet? = nil) {
        context = modelContext
        allWaypoints = ((try? modelContext.fetch(Waypoint.self)) ?? []).map {
            .init($0)
        }
        self.points = snippet?.points ?? []
        self.id = snippet?.sourceId
    }
    var legs: Set<RouteSnippet> = []
    var existingRoute: RouteSnippet?
    private var task: Task<(Set<RouteSnippet>, RouteSnippet?),Error>?
    private let cursorFactor = 1.5 // because my cursor is so large
}

// MARK: Save
extension RouteMaker {
    func save(isReviewed: Bool) -> Bool {
        let container = context.container
        let id = id
        let points = points
        let task = Task.detached {
            let actor = RouteLoader(modelContainer: container)
            try await actor.saveRoute(id: id, points: points, isReviewed: isReviewed)
        }
        Task {
            do {
                try await task.value
            } catch {
                logger.critical("There was an error saving the route: \(error)")
            }
        }
        return true
    }
}

// MARK: Actions
extension RouteMaker {
    func act(in region: MKCoordinateRegion) {
        guard canAct(in: region) else { return }
        switch state {
        case .addStart:
            if let wp = waypoint(in: region) {
                points.append(wp)
                Task {
                    await updateEnds()
                }
            }
        case .addEnd:
            if let wp = waypoint(in: region) {
                points.append(wp)
                Task {
                    await updateEnds()
                }
            }
        case .pickupOrSelect:
            if let i = index(at: region.center, threshold: region.closeEnoughThreshold.factor(cursorFactor)) {
                selectedIndex = i
            } else if let i = leg(at: region.center, threshold: region.closeEnoughThreshold.factor(cursorFactor)) {
                points.insert(.init(id: .init(), name: "", symbol: nil, tint: nil, latitude: region.center.latitude, longitude: region.center.longitude, isHub: false, isHarbour: false), at: i)
                isUncommited = true
                selectedIndex = i
            }
        case .dropOrDeselect:
            // must be true to be in this state anyway
            guard let selectedIndex else { return }
            
            // 1. If I'm dropping on an existing waypoint, we'll be using that, else we'll be creating new
            let wp = waypoint(in: region) ?? .init(id: .init(), name: "", symbol: nil, tint: nil, latitude: region.center.latitude, longitude: region.center.longitude, isHub: false, isHarbour: false)
            
            // 2. We can just put this into the collection because it has the appropriate id for new or existing and the one in the collection is separate from what has been saved.
            points[selectedIndex] = wp

            // 3. If I just dropped it into a straightaway, why keep it?
            // unpredictable - just let me manually remove what I don't want to keep
//            if selectedIsStraight {
//                points.remove(at: selectedIndex)
//            }
            
            isUncommited = false
            self.selectedIndex = nil
            
            if selectedIndex == 0 || selectedIndex == points.count - 1 {
                Task {
                    await updateEnds()
                }
            }
        }
    }
    func release() {
        switch state {
        case .addEnd:
            points = []
            Task {
                await updateEnds()
            }
        case .dropOrDeselect:
            if isUncommited,
               let i = selectedIndex
            {
                points.remove(at: i)
            }
            isUncommited = false
            selectedIndex = nil
        default:
            return
        }
    }
    func deleteFromRoute() {
        guard canDeleteFromRoute,
              let selectedIndex
        else { return }
        isUncommited = false
        self.selectedIndex = nil
        points.remove(at: selectedIndex)
        if points.count < 2 {
            // we must have deleted an end
            Task {
                await updateEnds()
            }
        }
    }
    func updateEnds() async {
        task?.cancel()
        guard !points.isEmpty else {
            self.legs = []
            self.existingRoute = nil
            return
        }
        let container = context.container
        let ends = ends.map { $0.id }.set
        let task = Task.detached {
            let actor = RouteLoader(modelContainer: container)
            let legs = try await actor.legs(endpoints: ends)
            let existing = try await actor.existingRoute(ends)
            return (legs, existing)
        }
        self.task = task
        do {
            let (legs, existing) = try await task.value
            self.legs = legs
            self.existingRoute = existing
        } catch {
            logger.critical("Couldn't fetch endpoint legs for route editor: \(error)")
        }
    }
}

// MARK: Derived
extension RouteMaker {
    func draggingPoints(in region: MKCoordinateRegion) -> [CLLocationCoordinate2D] {
        var copy = points.map { $0.coordinate }
        if let selectedIndex {
            copy[selectedIndex].latitude = region.center.latitude
            copy[selectedIndex].longitude = region.center.longitude
        }
        return copy
    }
    var name: String {
        if points.count > 1,
           let start = points.first,
           let end = points.last
        { "\(start.name) to \(end.name)" }
        else if points.count == 1,
                let start = points.first
        { "\(start.name) to "}
        else { "New Route" }
    }
    var description: String {
        "\(points.count.appending("waypoint", "waypoints")), \(points.totalDistance.converted(to: .nauticalMiles).value.formatted(.number.precision(.fractionLength(0...1)))) nm"
    }
    var start: WaypointSnippet? {
        points.first
    }
    var end: WaypointSnippet? {
        guard points.count > 1 else { return nil }
        return points.last
    }
    var ends: [WaypointSnippet] {
        [start, end].compactMap { $0 }
    }
    var newPoints: [WaypointSnippet] {
        points.enumerated().reduce(into: []) { partialResult, pair in
            if pair.0 != selectedIndex,
               !allWaypoints.contains(pair.1)
            { partialResult.append(pair.1) }
        }
    }
}

// MARK: Cursor
extension RouteMaker {
    /// Returns a fixed-position existing waypoint that we might be using as start, end, or dropping onto to use in our route
    ///
    /// The `scale` alters the threshold - more forgiving when zoomed out (large scale), more precise when zoomed in (small scale)
    func waypoint(in region: MKCoordinateRegion) -> WaypointSnippet? {
        allWaypoints.scoped(in: region, factor: cursorFactor)
    }
    func pickup(in region: MKCoordinateRegion) -> WaypointSnippet? {
        if let wp = waypoint(in: region) { return wp }
        if let i = index(at: region.center, threshold: region.closeEnoughThreshold.factor(cursorFactor)),
           i != selectedIndex
        {
            return points[i]
        }
        return nil
    }
    /// Returns index of a point currently on this route that we would like to select
    func index(at origin: CLLocationCoordinate2D, threshold: Measurement<UnitLength>) -> Int? {
        let box = origin.radius(threshold)
        var match: Int?
        for i in 0..<points.count {
            if box.contains(points[i].cgPoint) {
                guard match == nil else { return nil }
                match = i
            }
        }
        return match
    }
    /// Returns the index of the point at the start of the leg we would like to insert a grab point along
    func leg(at origin: CLLocationCoordinate2D, threshold: Measurement<UnitLength>) -> Int? {
        var match: Int?
        var reader = points.reader
        guard reader.countRemainder >= 2 else { return match }
        var lhs = reader.read()
        var rhs = lhs
        while !reader.didReachEnd {
            rhs = reader.read()
            if origin.is(between: lhs, and: rhs, crossTrackThreshold: threshold) {
                guard match == nil else { return nil }
                match = reader.currentIndex - 1
            }
            lhs = rhs
        }
        return match
    }
}

// MARK: Mode / Step / State
extension RouteMaker {
    var state: EditingState {
        if points.isEmpty { .addStart }
        else if points.count == 1 { .addEnd }
        else if selectedIndex == nil { .pickupOrSelect }
        else { .dropOrDeselect }
    }
    enum EditingState {
        case addStart, addEnd, pickupOrSelect, dropOrDeselect
        var cursorImage: String {
            switch self {
            case .addStart, .addEnd:
                "scope"
            case .pickupOrSelect:
                "hand.point.up.left"
            case .dropOrDeselect:
                "circle.circle"
//                "dot.circle.and.hand.point.up.left.fill"
            }
        }
    }
    func canAct(in region: MKCoordinateRegion) -> Bool {
        switch state {
        case .addStart, .addEnd:
            guard let wp = waypoint(in: region) else { return false }
            return wp.isMajor
        case .pickupOrSelect:
            if let _ = index(at: region.center, threshold: region.closeEnoughThreshold.factor(cursorFactor)) { return true }
            if let _ = leg(at: region.center, threshold: region.closeEnoughThreshold.factor(cursorFactor)) { return true }
            return false
        case .dropOrDeselect:
            if selectedIndex == 0 || selectedIndex == points.count - 1
            {
                guard let wp = waypoint(in: region) else { return false }
                return wp.isMajor
            }
            return true
        }
    }
    var canDeleteFromRoute: Bool {
        guard let selectedIndex else { return false }
        if selectedIndex == 0 || selectedIndex == points.count - 1
        {
            return points.count <= 2
        } else {
            return !isUncommited
        }
    }
    /// As in if the selected point is exactly between its neighbours - either because new or not worth keeping.
    var selectedIsStraight: Bool {
        if let i = selectedIndex {
            if i != 0, i < points.count - 1 {
                if points[i].is(between: points[i-1], and: points[i+1]) {
                    return true
                }
            }
        }
        return false
    }
    /// You can save it if it has the two ends.
    var canSave: Bool {
        points.count > 1
    }
}
