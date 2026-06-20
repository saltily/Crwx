//
//  NobActor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/18/25.
//

import Foundation
import SwiftData
import FoundationSalt
import UniformTypeIdentifiers
import os
extension UTType {
    static var nob: UTType {
        UTType(importedAs: "com.rosepoint.nob", conformingTo: xml)
    }
}

@ModelActor
final actor NobActor {
    var existingWaypoints: [UUID: Waypoint] = [:]
    var existingWaypointStamps: [String: Waypoint] = [:]
    var existingRoutes: Set<UUID> = []

    func load(parsers: [NobParser], tracker: ProgressTracker<Void>) async throws {
        
        // 1. Read in for deduplication
        try loadExistingWaypoints()
        try loadExistingRoutes()
        
        // 2. For each file that was parsed
        // tracker adds up all the marks and routes in all the parsers
        for (i, parser) in parsers.enumerated() {
            try Task.checkCancellation()
            await tracker.set(label: "\(i+1) of \(parsers.count) - \(parser.url?.deletingPathExtension().lastPathComponent ?? "unnamed")")
            
            // 3. Parse and save all new waypoints
            for (i, _) in parser.markTrees.enumerated() {
                try Task.checkCancellation()
                load(waypoint: try parser.waypoint(at: i))
                await tracker.advance()
            }
            
            // 4. Parse and save all new routes
            for (i, _) in await parser.routeTrees.enumerated() {
                try Task.checkCancellation()
                try await load(route: try parser.route(at: i))
                await tracker.advance()
            }
            
            // 5. Delete the file
            if let url = parser.url {
                try Task.checkCancellation()
                try FileManager.default.removeItem(at: url)
            }
            let debug = await parser.debugDescription
            await logger.info("\(debug)")
        }
        
        // 6. Save the context
        try Task.checkCancellation()
        try modelContext.save()
        let wp_ct = try modelContext.fetchCount(Waypoint.self)
        let rt_ct = try modelContext.fetchCount(Route.self)
        await logger.info("There are now \(wp_ct) waypoints and \(rt_ct) routes in the database")
    }
    
    private func loadExistingWaypoints() throws {
        let waypoints = try modelContext.fetch(Waypoint.self)
        existingWaypoints = waypoints.reduce(into: [:]) { partialResult, wp in
            partialResult[wp.id] = wp
        }
        existingWaypointStamps = waypoints.reduce(into: [:]) { partialResult, wp in
            partialResult[wp.stamp] = wp
        }
    }
    private func loadExistingRoutes() throws {
        existingRoutes = try modelContext.fetch(Route.self).map {
            $0.id
        }.set
    }
    
    
    private func load(waypoint: Waypoint) {
        // see if it exists
        let existing: Waypoint?
        if let match = existingWaypoints[waypoint.id] {
            existing = match
        } else if let match = existingWaypointStamps[waypoint.stamp],
                  match.source != "RosePoint"
        {
            // reidentify because RosePoint needs to control the id
            existingWaypoints[match.id] = nil
            match.id = waypoint.id
            match.source = "RosePoint"
            existingWaypoints[waypoint.id] = match
            existing = match
        } else {
            existing = nil
        }
        if let existing {
            // copy in name and symbol if more meaningful than before
            if let _ = Int(existing.name) {
                existing.name = waypoint.name
            }
            if existing._symbol == nil {
                existing._symbol = waypoint._symbol
            }
            if existing.latitude != waypoint.latitude ||
                existing.longitude != waypoint.longitude
            {
                logger.trace("Existing location was \(existing.latitude), \(existing.longitude)\nand now it will be \(waypoint.latitude), \(waypoint.longitude)")
                existing.latitude = waypoint.latitude
                existing.longitude = waypoint.longitude
            }
            existing.created = waypoint.created
            return
        }
        // insert if it dosn't exist
        existingWaypoints[waypoint.id] = waypoint
        existingWaypointStamps[waypoint.stamp] = waypoint
        modelContext.insert(waypoint)
    }
    
    private func load(route: Route) throws {
        if existingRoutes.contains(route.id) { return }
        let waypoints = route.waypointIds
        var waypointRelationship = [Waypoint]()
        try waypoints.forEach {
            guard let wp = existingWaypoints[$0]
            else { throw ParseError.MissingRouteWaypoint }
            waypointRelationship.append(wp)
        }
        route.waypointsUsed = waypointRelationship
        guard let startId = waypoints.first,
              let endId = waypoints.last,
              let start = existingWaypoints[startId],
              let end = existingWaypoints[endId]
        else { throw ParseError.MissingRouteEndpoint }
        route.endpointNames = .endpointNames(start, end)
        route.endpointIds = .endpointIds(start, end)
        route.endpointStamps = .endpointStamps(start, end)
        existingRoutes.insert(route.id)
        modelContext.insert(route)
    }

}
extension String {
    static func endpointNames(_ lhs: Waypoint, _ rhs: Waypoint) -> String {
        "\(lhs.name) - \(rhs.name)"
    }
    static func endpointIds(_ lhs: Waypoint, _ rhs: Waypoint) -> String {
        "\(lhs.id.uuidString) - \(rhs.id.uuidString)"
    }
    static func endpointStamps(_ lhs: Waypoint, _ rhs: Waypoint) -> String {
        "\(lhs.stamp) - \(rhs.stamp)"
    }
}
