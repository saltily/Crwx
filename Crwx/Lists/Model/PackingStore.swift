//
//  PackingStore.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation

/// The idea behind this type is to have something I can inject through for development that is view-model based, and then later convert this same type over to be backed by SwiftData to persist between launches.
@Observable
final class PackingStore {
    // eventually this should take model context and load up the items from the store
    // unfortunately that single load won't reload when things sync in from the cloud - perhaps have a pull-to-refresh thing
    init() {}
    var allItems: [PackableItem] = []
}

// MARK: Basic Editing Features
extension PackingStore {
    func save() throws {
        // eventually hook this up for when attached to a SwiftData store.
        // inverse I think should just be loading when initialised with a context.
    }
    func remove(id: UUID) {
        remove(ids: [id])
    }
    func remove(ids: Set<UUID>) {
        allItems.removeAll(where: {
            ids.contains($0.id)
        })
    }
    func add(items: [PackableItem]) {
        let allIds = allItems.map(\.id)
        for item in items {
            
        }
    }
}
