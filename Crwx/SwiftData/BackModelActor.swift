//
//  BackModelActor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/13/25.
//

import Foundation
import SwiftData
import FoundationSalt
import WxSalt
import os

// MARK: - Save Location Profile
@ModelActor
final actor BackModelActor {
    @discardableResult
    func save(harbour: HarbourViewModel) async throws -> PersistentIdentifier {
        let model: Harbour
        if let persistentId = harbour.persistentId {
            guard let existing = self[persistentId, as: Harbour.self]
            else { throw E.BadId }
            model = existing
            model.name = harbour.name
            model.waypoint?.name = harbour.name
            if let wp = model.waypoint,
               let routes = wp.routes
            {
                for route in routes.filter({
                    $0.endpointIds.contains(wp.id.uuidString)
                }) {
                    route.regenerateName()
                }
            }
            model.notes = harbour.notes
        } else {
            let new = Harbour(id: harbour.id, name: harbour.name, latitude: harbour.latitude, longitude: harbour.longitude, notes: harbour.notes)
            model = new
            modelContext.insert(new)
            let wp = Waypoint(id: harbour.id, source: "", latitude: harbour.latitude, longitude: harbour.longitude, name: harbour.name, _symbol: WaypointSymbol.anchor.rawValue, created: .now, imported: nil, stamp: .stamp(latitude: harbour.latitude, longitude: harbour.longitude))
            modelContext.insert(wp)
            wp.harbour = new
            new.waypoint = wp
        }
        model.waypoint?.tint = harbour.tint
        model.bottomType = harbour.bottom
        model.chartDepth = harbour.depth
        model.entranceDepth = harbour.entranceDepth
        model.windExposure = harbour.exposure
        model.swellExposure = harbour.swellExposure
        model.rating = harbour.rating
        model.facilities = harbour.facilities
        model.protectionScore = harbour.protectionScore
        model.protectionHighlights = harbour.protectionHighlights
        model.guideRating = .init(percentage: harbour.guideRating)
        // cache old cruising guide
        if model.cruisingGuide.year != harbour.cruisingGuide.year,
           !harbour.cruisingGuide.isEmpty
        {
            model.cruisingGuide.cached = harbour.cruisingGuide.encoded
        }
        model.cruisingGuide = harbour.cruisingGuide
        try modelContext.save()
        return model.persistentModelID
    }
    func remove(harbour id: PersistentIdentifier) async throws {
        guard let harbour = self[id, as: Harbour.self]
        else { throw E.BadId }
        if let wp = harbour.waypoint {
            // keep the waypoint if it is included in routes
            if wp.routes?.count.nilIfZero == nil {
                modelContext.delete(wp)
            }
        }
        // I'm not doing anything to tweak trips if they are losing their harbour
        // mostly because I don't anticipate removing those types of harbours (just the ones I created but never used)
        modelContext.delete(harbour)
        try modelContext.save()
    }
    func save(location: LocationProfileViewModel) async throws -> PersistentIdentifier {
        if let persistentId = location.persistentId {
            guard let existing = self[persistentId, as: LocationProfile.self]
            else { throw E.BadId }
            existing.name = location.name
            existing.index = location.index
            existing.point = location.point
            existing.airport = location.observations
            existing.marinePoint = location.marinePoint
            existing.zone = location.zone
            existing.buoy = location.buoy
            existing.tides = location.tides
            existing.currents = location.currents
            try modelContext.save()
            return persistentId
        } else {
            let new = LocationProfile(viewModel: location)
            modelContext.insert(new)
            try modelContext.save()
            new.index = try modelContext.fetchCount(LocationProfile.self)
            try modelContext.save()
            return new.persistentModelID
        }
    }
    func save(track: TrackNameViewModel) async throws {
        guard let existing = self[track.persistentId, as: Track.self]
        else { throw E.BadId }
        existing.name = track.name
        existing.date = track.date
        try modelContext.save()
    }
    enum E: Error {
        case BadId
        case MissingWaypoint
        case EmptyRoute
    }
}


// MARK: - Refresh Route Names
extension BackModelActor {
    /// This will go through endpoint names and route names to try to fill in any missing information
    func refreshRouteNames() async throws {
        
        // 1. Get all routes whose first endpoint is unnamed
        var matches = try modelContext.fetch(#Predicate<Route> {
            $0.endpointNames.starts(with: " - ")
        })
        
        // 2. Group them by first endpoint id
        var matchGroups = matches.grouped(by: \.start)
        
        // 3. For each start id, try to get name from route name
        for group in matchGroups {
            if let startName = group.first?.name.components(separatedBy: " to ").first,
               !startName.isEmpty,
               let waypoint = Waypoint.find(group.id?.id, in: modelContext)
            {
                
                // 4. When setting name to waypoint, find all routes that use this waypoint and update their name stamp and name
                if waypoint.name.isEmpty { waypoint.name = startName }
                if waypoint._symbol == nil { waypoint.symbol = .anchor }
                try await rename(waypoint: waypoint.persistentModelID)
            }
        }
        
        // 5. Get all routes whose last endpoint is unnamed and repeat
        // Unfortunately, there's no Swift Predicate for ENDSWITH
        matches = try modelContext.fetch(Route.self).filter {
            $0.endpointNames.hasSuffix(" - ")
        }
        matchGroups = matches.grouped(by: \.end)
        for group in matchGroups {
            if let endName = group.first?.name.components(separatedBy: " to ").last,
               !endName.isEmpty,
               let waypoint = Waypoint.find(group.id?.id, in: modelContext)
            {
                if waypoint.name.isEmpty { waypoint.name = endName }
                if waypoint._symbol == nil { waypoint.symbol = .anchor }
                try await rename(waypoint: waypoint.persistentModelID)
            }
        }
        
        // 6. Get all unnamed routes and generate a name from endpoints
        matches = try modelContext.fetch(#Predicate<Route> {
            $0.name == ""
        })
        logger.trace("The number of routes with empty names is \(matches.count)")
        for route in matches {
            route.regenerateName()
        }
        
        // 7. Save context
        try modelContext.save()
        
    }
    /// When renaming a waypoint, find all routes that use this waypoint and update their name stamp and name
    func rename(waypoint persistentId: PersistentIdentifier) async throws {
        guard let waypoint = self[persistentId, as: Waypoint.self]
        else { throw E.BadId }
        let idString = waypoint.id.uuidString
        let routes = try modelContext.fetch(#Predicate<Route> {
            $0.endpointIds.contains(idString)
        })
        for route in routes {
            try route.restamp(in: modelContext)
        }
    }
}
