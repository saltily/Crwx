//
//  PackingStore.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation
import FoundationSalt

/// The idea behind this type is to have something I can inject through for development that is view-model based, and then later convert this same type over to be backed by SwiftData to persist between launches.
@Observable
final class PackingStore {
    // eventually this should take model context and load up the items from the store
    // unfortunately that single load won't reload when things sync in from the cloud - perhaps have a pull-to-refresh thing
    convenience init() { self.init(items: []) }
    var allItems: [PackableItem]
    private init(items: [PackableItem]) {
        self.allItems = items
    }
}


// MARK: Counts
extension PackingStore {
    func count(for filter: PackingFilter?) -> Int {
        guard let filter else { return 0 }
        return allItems.count { item in
            filter.matches(item)
        }
    }
    func viewModel(for filter: PackingFilter) -> PackingListViewModel {
        .init(filter: filter, items: allItems.filter({ filter.matches($0) }).map({ .init(contents: $0, filter: filter) }))
    }
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
        let allIds = allItems.map(\.id).set
        for item in items {
            if !allIds.contains(item.id) {
                allItems.append(item)
            }
        }
    }
}


// MARK: Samples
extension PackingStore: ExpressibleByArrayLiteral {
    static var sample: PackingStore {
        [
            // take out
            .init("muck boots", status: .takeOut),
            .init("full water jugs", status: .takeOut),
            .init("drill", status: .takeOut),
            .init("nitrile gloves", status: .packed),
            .init("brush", status: .takeOut),
            .init("fill water tank", status: .takeOut, configuration: .dockside),
            .init("chart card", status: .takeOut),
            // bring in
            .init("bimini", status: .bringIn, configuration: .dockside),
            .init("empty water jugs", status: .bringIn),
            // purchase
            .init("diesel", status: .purchase),
            .init("lighter sticks", status: .purchase),
            .init("can opener", status: .purchase),
            .init("percolator filters", status: .purchase),
            // prep
            .init("chicken salad", status: .prep)
        ]
    }
    convenience init(arrayLiteral elements: PackableItem...) {
        self.init(items: elements)
    }
}


// MARK: App Events
extension PackingStore {
    func beginDaysail() {
        markDue(lifecycle: .daysail, direction: .out)
    }
    func endDaysail() {
        markDue(lifecycle: .daysail, direction: .in)
    }
    func beginCruise() {
        markDue(lifecycle: .cruise, direction: .out)
    }
    func endCruise() {
        markDue(lifecycle: .cruise, direction: .in)
    }
    func beginSeason() {
        markDue(lifecycle: .seasonal, direction: .out)
    }
    func endSeason() {
        markDue(lifecycle: .seasonal, direction: .in)
    }
    private func markDue(lifecycle: PackedLifecycle, direction: PackedStatus.Direction) {
        for item in allItems {
            if item.configuration.lifecycle.contains(lifecycle),
               item.state.status.direction == direction
            {
                item.state.due = .anytime
            }
        }
    }
}
