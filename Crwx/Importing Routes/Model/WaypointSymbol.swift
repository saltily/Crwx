//
//  WaypointSymbol.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI

enum WaypointSymbol: Equatable, Hashable, Codable {
    case anchor, waypoint, greenAnchor, greenCross, square
    case hub
    case unknown(String)
}

extension WaypointSymbol {
    init?(rawValue: String?) {
        guard let rawValue,
              !rawValue.isEmpty
        else { return nil }
        switch rawValue {
        case "Anchor": self = .anchor
        case "Waypoint": self = .waypoint
        case "Green Anchor": self = .greenAnchor
        case "Green Cross": self = .greenCross
        case "Square": self = .square
        case "Hub": self = .hub
        default: self = .unknown(rawValue)
        }
    }
    var rawValue: String {
        switch self {
        case .anchor: return "Anchor"
        case .waypoint: return "Waypoint"
        case .greenAnchor: return "Green Anchor"
        case .greenCross: return "Green Cross"
        case .square: return "Square"
        case .hub: return "Hub"
        case .unknown(let string): return string
        }
    }
    var colour: Color? {
        switch self {
        case .greenCross, .greenAnchor: return .green
        default: return nil
        }
    }
    var systemImage: String {
        switch self {
        case .anchor, .greenAnchor: return "parkingsign.circle"
        case .greenCross: return "cross"
        case .waypoint: return "mappin"
        case .square: return "square"
        case .hub: return "point.3.connected.trianglepath.dotted"
        case .unknown: return "questionmark"
        }
    }
}

// MARK: Codable
extension WaypointSymbol {
    enum CodingKeys: CodingKey {
        case rawValue
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(String.self, forKey: .rawValue)
        self.init(rawValue: rawValue)!
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawValue, forKey: .rawValue)
    }
}
