//
//  InventoryListItem.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/23/26.
//

import Foundation
import FoundationSalt

/// Rough sketch placeholder for a viewmodel.  We'll want this to have a packable item backing.  And it will need to know if we're doing boat or shore inventory.  And update last inventoried when changing stuff.
/// I want this to rollback like `PackingListItem`.
@Observable
final class InventoryListItem: CheckedRollbackProtocol {
    init(contents: PackableItem, style: Style) {
        self.checked = false // maybe true if recently inventoried
        self.contents = contents
        self.style = style
        self.uncheckedRollback = .init(inventory: contents.state.inventory, lastInventoried: contents.lastInventoried)
    }
    var checked: Bool {
        didSet {
            contents.lastInventoried = .now
            rollback()
        }
    }
    let contents: PackableItem
    let uncheckedRollback: Rollback
    let style: Style
    enum Style {
        case shore, boat
    }
    struct Rollback {
        let inventory: PackableItem.Inventory
        let lastInventoried: Date?
    }
    enum Grouping: Int, CaseIterable {
        case category, locker
        struct Value: Comparable, Hashable {
            let n: String
            let label: String
            static func < (lhs: Value, rhs: Value) -> Bool {
                compare(lhs: lhs, rhs: rhs, using: .init(\.n)) == .orderedAscending
            }
        }
        var systemImage: String {
            switch self {
            case .locker: "location"
            case .category: "swatchpalette"
            }
        }
        var label: String {
            switch self {
            case .locker: "locker"
            case .category: "category"
            }
        }
    }
}

extension InventoryListItem: Identifiable {
    var id: UUID { contents.id }
    var categoryKey: Grouping.Value {
        let category = contents.configuration.category
        return .init(n: category?.rawValue ?? "zzzzzz", label: category?.description.capitalized ?? "No Category")
    }
    var lockerKey: Grouping.Value {
        let locker = contents.configuration.locker
        return .init(n: "\(locker?.sortValue ?? 100)", label: locker?.description.capitalized ?? "Unknown Location")
    }
    var sortDate: Date {
        contents.lastShift?.date ?? contents.created
    }
}

extension InventoryListItem {
    var quantity: Double {
        get {
            switch style {
            case .boat: contents.state.inventory.quantityOnBoat
            case .shore: contents.state.inventory.quantityOnShore
            }
        }
        set {
            let oldValue = quantity
            switch style {
            case .boat: contents.state.inventory.quantityOnBoat = newValue
            case .shore: contents.state.inventory.quantityOnShore = newValue
            }
            if oldValue != newValue {
                didChangeQuantity(oldValue: oldValue, newValue: newValue)
                checked = true
            }
        }
    }
    var otherQuantity: Double {
        switch style {
        case .shore: contents.state.inventory.quantityOnBoat
        case .boat: contents.state.inventory.quantityOnShore
        }
    }
    var label: String { contents.label }
    var specs: String? { contents.configuration.specs.nilIfEmpty }
    var nextStepsSentence: String { contents.stepsSummary }
    var matchingCountSentence: String {
        let s = otherQuantity.formatted(.number)
        switch style {
        case .boat:
            return "Maybe \(s) on shore."
        case .shore:
            return "Maybe \(s) on boat."
        }
    }
    var historySentence: String? {
        guard let lastInventoried = contents.lastInventoried else { return nil }
        let s = lastInventoried.formatted(.relative(presentation: .named))
        return "Last inventoried \(s)."
    }
    var isConsumable: Bool {
        contents.isConsumable
    }
    func rollback() {
        if !checked {
            contents.state.inventory = uncheckedRollback.inventory
            contents.lastInventoried = uncheckedRollback.lastInventoried
        }
    }
    func increment() {
        switch style {
        case .boat: contents.state.inventory.incrementOnBoat()
        case .shore: contents.state.inventory.incrementOnShore()
        }
        checked = true
    }
    func decrement() {
        switch style {
        case .boat: contents.state.inventory.decrementOnBoat(consumable: contents.isConsumable)
        case .shore: contents.state.inventory.decrementOnShore()
        }
        checked = true
    }
    private func didChangeQuantity(oldValue: Double, newValue: Double) {
        if style == .boat {
            let delta = newValue - oldValue
            contents.state.inventory.didIncrementOnBoat(delta, consumable: contents.isConsumable)
        }
    }
}


// MARK: Sorting
extension [InventoryListItem] {
    func organise(by grouping: InventoryListItem.Grouping) -> [SectionGroup<InventoryListItem.Grouping.Value, [InventoryListItem]>] {
        switch grouping {
        case .category:
            return self.sorted(by: [
                .init(\.categoryKey),
                .init(\.checked.int),
                .init(\.sortDate, order: .reverse)
            ]).grouped(by: \.categoryKey)
        case .locker:
            return self.sorted(by: [
                .init(\.lockerKey),
                .init(\.checked.int),
                .init(\.categoryKey),
                .init(\.sortDate, order: .reverse)
            ]).grouped(by: \.lockerKey)
        }
    }
}
