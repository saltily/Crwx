//
//  Library+Entertainment.swift
//  Crwx
//
//  Created by Matthew Goacher on 8/1/26.
//

import Foundation

/// 6 items
/// Imported 8/1/2026, 2:33 pm
extension PackableItemDefinition {
    static var lanterns: PackableItemDefinition {
        .init(id: UUID(uuidString: "12A6A347-2CD2-4AB0-A7A6-58EB7AE355DC")!, name: "lanterns", category: .entertainment, lifecycle: .permanent, consumable: nil, locker: .closets, requiresDockside: true)
    }
    static var playingCards: PackableItemDefinition {
        .init(id: UUID(uuidString: "0A81F748-6129-4C83-809A-52CFDB0CC744")!, name: "playing cards", category: .entertainment, lifecycle: .permanent, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var cribbageBoard: PackableItemDefinition {
        .init(id: UUID(uuidString: "BE344E45-F000-418D-9AC4-CF817EB54AC0")!, name: "cribbage board", category: .entertainment, lifecycle: .permanent, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var guitar: PackableItemDefinition {
        .init(id: UUID(uuidString: "BB11E0AC-77E5-4E5E-85DF-7BE087F85AAB")!, name: "guitar", category: .entertainment, lifecycle: .cruise, consumable: nil, locker: .aftSettee, requiresDockside: true)
    }
    static var readingMaterials: PackableItemDefinition {
        .init(id: UUID(uuidString: "6427462C-5AFE-49F1-B46D-4FEE21B59519")!, name: "reading materials", category: .entertainment, lifecycle: .cruise, consumable: nil, locker: .portBookshelf, requiresDockside: false)
    }
    static var laptop: PackableItemDefinition {
        .init(id: UUID(uuidString: "194D5696-612C-4212-9538-175E1FB9C73E")!, name: "laptop", category: .entertainment, lifecycle: .cruise, consumable: nil, locker: .portTable, requiresDockside: false)
    }
}
