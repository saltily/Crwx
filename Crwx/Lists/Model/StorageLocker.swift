//
//  StorageLocker.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation

/// Represents where it would be stored on the boat.  Helpful to organise inventory so not backtracking.  A little like knowing which aisle in a store.
enum StorageLocker: String, Codable, Sendable, Hashable, CaseIterable {
    case veeBerth, closets, head
    case starboardSettee, starboardBookshelf
    case portBookshelf, portTable
    case navTable, aftSettee
    case galley, iceBox
    case cockpit, onDeck
}

extension StorageLocker: CustomStringConvertible {
    var description: String {
        switch self {
        case .veeBerth: "vee berth"
        case .starboardSettee: "stbd settee"
        case .starboardBookshelf: "stbd bookshelf"
        case .portBookshelf: "port bookshelf"
        case .portTable: "port table"
        case .navTable: "nav table"
        case .aftSettee: "aft settee"
        case .iceBox: "ice box"
        case .onDeck: "on deck"
        default: rawValue
        }
    }
}
