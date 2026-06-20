//
//  WaypointSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import Foundation
import SwiftUI
import FoundationSalt
import CoreLocation

struct WaypointSnippet: Identifiable, Sendable, Mappable, Hashable, Codable {
    let id: UUID
    let name: String
    let symbol: WaypointSymbol?
    let tint: Color?
    let latitude: Double
    let longitude: Double
    var formattedAddress: String? { nil }
    let isHub: Bool
    let isHarbour: Bool
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension WaypointSnippet {
    init(_ waypoint: Waypoint) {
        id = waypoint.id
        name = waypoint.name
        symbol = waypoint.symbol
        tint = waypoint.tint
        latitude = waypoint.latitude
        longitude = waypoint.longitude
        isHub = waypoint.isHub
        isHarbour = waypoint.isHarbour
    }
    init(_ harbour: Harbour) {
        id = harbour.id
        name = harbour.name
        symbol = .anchor
        tint = harbour.tint
        latitude = harbour.latitude
        longitude = harbour.longitude
        isHub = false
        isHarbour = true
    }
    init(_ harbour: HarbourViewModel) {
        id = harbour.id
        name = harbour.name
        symbol = .anchor
        tint = harbour.tint
        latitude = harbour.latitude
        longitude = harbour.longitude
        isHub = false
        isHarbour = true
    }
    var stamp: String {
        "\(latitude.rounded(0.000_01)),\(longitude.rounded(0.000_01))"
    }
}
extension [WaypointSnippet] {
    var stamp: String {
        self.map {
            $0.stamp
        }.sorted().joined(separator: "|")
    }
}

extension WaypointSnippet {
    var label: String? { name }
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    static func make(from point: any Mappable) -> WaypointSnippet? {
        point as? WaypointSnippet
    }
}

// MARK: Codable
extension WaypointSnippet {
    enum CodingKeys: CodingKey {
        case id, name, symbol, tint, latitude, longitude, isHub, isHarbour
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decodeIfPresent(WaypointSymbol.self, forKey: .symbol)
        tint = try container.decodeIfPresent(Color.self, forKey: .tint)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        isHub = try container.decode(Bool.self, forKey: .isHub)
        isHarbour = try container.decode(Bool.self, forKey: .isHarbour)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(symbol, forKey: .symbol)
        try container.encodeIfPresent(tint, forKey: .tint)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(isHub, forKey: .isHub)
        try container.encode(isHarbour, forKey: .isHarbour)
    }
}
