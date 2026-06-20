//
//  CompassQuadrant.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import Foundation

enum CompassQuadrant: String, Hashable, Sendable, Codable {
    case north, south, east, west
}

extension CompassQuadrant: CustomStringConvertible {
    var description: String {
        rawValue
//        switch self {
//        case .north:
//            "north"
//        case .south:
//            "south"
//        case .east:
//            "east"
//        case .west:
//            "west"
//        }
    }
}
