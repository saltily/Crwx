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
    case portBookshelf, portTable, boatswainDrawer
    case navTable, aftSettee
    case galley, iceBox
    case cockpit, onDeck
}

extension StorageLocker: CustomStringConvertible {
    var description: String {
        switch self {
        case .veeBerth: "vee berth"
        case .starboardSettee: "starboard settee"
        case .starboardBookshelf: "starboard bookshelf"
        case .portBookshelf: "port bookshelf"
        case .portTable: "port table"
        case .boatswainDrawer: "boatswain drawer"
        case .navTable: "nav table"
        case .aftSettee: "aft settee"
        case .iceBox: "ice box"
        case .onDeck: "on deck"
        default: rawValue
        }
    }
    var sortValue: Int {
        switch self {
        case .veeBerth: 1
        case .closets: 2
        case .head: 3
        case .starboardSettee: 4
        case .starboardBookshelf: 5
        case .portBookshelf: 6
        case .portTable: 7
        case .boatswainDrawer: 8
        case .navTable: 9
        case .aftSettee: 10
        case .galley: 11
        case .iceBox: 12
        case .cockpit: 13
        case .onDeck: 14
        }
    }
}
