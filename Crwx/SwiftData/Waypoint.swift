//
//  Waypoint.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import SwiftData
import FoundationSalt
import CoreLocation

typealias Waypoint = CurrentSchema.Waypoint

// symbol should be an enum, but I'm not sure what the options will be yet

extension Waypoint {
    var isStandalone: Bool {
        _symbol != nil
    }
    var isHarbour: Bool {
        harbour != nil
    }
    var symbol: WaypointSymbol? {
        get { .init(rawValue: _symbol) }
        set { _symbol = newValue?.rawValue }
    }
    var importSource: ImportSource? {
        get { .init(rawValue: source) }
    }
    var tint: Color? {
        get { .init(decoding: _tint) ?? symbol?.colour }
        set {
            if newValue?.hex == symbol?.colour?.hex {
                _tint = nil
            } else if newValue?.hex == "000000",
                      symbol == .greenAnchor
            {
                symbol = .anchor
                _tint = nil
            } else {
                _tint = newValue?.encoded
            }
        }
    }
}
extension Waypoint: Mappable {
    var label: String? { name }
    var formattedAddress: String? { nil }
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    static func make(from point: any Mappable) -> Waypoint? {
        point as? Waypoint
    }
}

// MARK: Fetching
extension Waypoint {
    static func find(_ id: UUID?, in context: ModelContext) -> Waypoint? {
        guard let id else { return nil }
        return try? context.fetchOne(#Predicate {
            $0.id == id
        })
    }
    static func mapping(_ ids: [UUID], in context: ModelContext) throws -> [Waypoint] {
        let waypoints = try context.fetch(#Predicate<Waypoint> {
            ids.contains($0.id)
        }).reduce(into: [:]) { partialResult, wp in
            partialResult[wp.id] = wp
        }
        return try ids.map {
            guard let wp = waypoints[$0] else { throw BackModelActor.E.MissingWaypoint }
            return wp
        }
    }
}
extension Predicate {
    static var hubs: Predicate<Waypoint> {
        #Predicate {
            $0.isHub
        }
    }
}
extension [SortDescriptor<Waypoint>] {
    static var defaultOrder: Self {
        [
            .init(\.longitude, order: .reverse),
            .init(\.latitude, order: .reverse),
            .init(\.created, order: .reverse),
        ]
    }
}
