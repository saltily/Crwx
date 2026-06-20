//
//  GpxActor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/18/25.
//

import Foundation
import FoundationSalt
import SwiftData
import UniformTypeIdentifiers
extension UTType {
    static var gpx: UTType {
        UTType(importedAs: "com.topografix.gpx", conformingTo: xml)
    }
}

@ModelActor
final actor GpxActor {
    var existingWaypoints: Set<String> = [] // stamps
    var existingTracks: [String: Set<Data>] = [:] // stamps and points data
    
    func load(parsers: [GpxParser], tracker: ProgressTracker<Void>) async throws {
        
        // 1. Read in for deduplication
        try loadExistingWaypoints()
        try loadExistingTracks()
        
        // 2. For each file that was parsed
        // tracker adds up all the waypoints and tracks in all the parsers
        for (i, parser) in parsers.enumerated() {
            try Task.checkCancellation()
            await tracker.set(label: "\(i+1) of \(parsers.count) - \(parser.url?.deletingPathExtension().lastPathComponent ?? "unnamed")")
            
            // 3. Parse and save all new waypoints
            for (i, _) in parser.waypointTrees.enumerated() {
                try Task.checkCancellation()
                load(waypoint: try parser.waypoint(at: i))
                await tracker.advance()
            }
            
            // 4. Parse and save all new tracks
            for (i, _) in parser.trackTrees.enumerated() {
                try Task.checkCancellation()
                load(track: try parser.track(at: i))
                await tracker.advance()
            }
            
            // 5. Delete the file
            if let url = parser.url {
                try Task.checkCancellation()
                try FileManager.default.removeItem(at: url)
            }
            logger.info("\(parser.debugDescription)")
        }
        
        // 6. Save the context
        try Task.checkCancellation()
        try modelContext.save()
        let wp_ct = try modelContext.fetchCount(Waypoint.self)
        let tk_ct = try modelContext.fetchCount(Track.self)
        logger.info("There are now \(wp_ct) waypoints and \(tk_ct) tracks in the database")
    }
    
    private func loadExistingWaypoints() throws {
        let waypoints = try modelContext.fetch(Waypoint.self)
        existingWaypoints = waypoints.map {
            $0.stamp
        }.set
    }
    private func loadExistingTracks() throws {
        existingTracks = try modelContext.fetch(Track.self).reduce(into: [:]) { partialResult, t in
            if let data = t._points {
                var array = partialResult[t.stamp] ?? []
                array.insert(data)
                partialResult[t.stamp] = array
            }
        }
    }
    private func load(waypoint: Waypoint) {
        // see if it exists
        if existingWaypoints.contains(waypoint.stamp)
        { return }
        // insert if it dosn't exist
        existingWaypoints.insert(waypoint.stamp)
        modelContext.insert(waypoint)
    }
    private func load(track: Track) {
        // see if it exists
        if let data = track._points,
           let matches = existingTracks[track.stamp],
           matches.contains(data)
        { return }
        // insert if it dosn't exist
        if let data = track._points {
            var array = existingTracks[track.stamp] ?? []
            array.insert(data)
            existingTracks[track.stamp] = array
        }
        modelContext.insert(track)
    }

}
