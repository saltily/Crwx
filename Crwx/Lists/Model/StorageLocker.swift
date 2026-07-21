//
//  StorageLocker.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation

/// Represents where it would be stored on the boat.  Helpful to organise inventory so not backtracking.  A little like knowing which aisle in a store.
enum StorageLocker: String, Codable, Sendable, Hashable {
    case veeBerth, closets, head
    case starboardSettee, starboardBookshelf
    case portBookshelf, portTable
    case navTable, aftSettee
    case galley, iceBox
    case cockpit, onDeck
}
