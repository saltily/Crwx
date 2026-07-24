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
    init(checked: Bool = false, contents: PackableItem, style: Style) {
        self.checked = checked
        self.contents = contents
        self.style = style
        self.uncheckedRollback = contents.lastInventoried
    }
    var checked: Bool {
        didSet {
            contents.lastInventoried = .now
            rollback()
        }
    }
    let contents: PackableItem
    let uncheckedRollback: Date?
    let style: Style
    enum Style {
        case shore, boat
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
    var specs: String? { contents.configuration.specs }
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
        guard let uncheckedRollback else { return nil }
        let s = uncheckedRollback.formatted(.relative(presentation: .named))
        return "Last inventoried \(s)."
    }
    var isConsumable: Bool {
        contents.isConsumable
    }
    func rollback() {
        if !checked {
            contents.lastInventoried = uncheckedRollback
        }
    }
    func increment() {
        switch style {
        case .boat: contents.state.inventory.incrementOnBoat()
        case .shore: contents.state.inventory.incrementOnShore()
        }
    }
    func decrement() {
        switch style {
        case .boat: contents.state.inventory.decrementOnBoat(consumable: contents.isConsumable)
        case .shore: contents.state.inventory.decrementOnShore()
        }
    }
    private func didChangeQuantity(oldValue: Double, newValue: Double) {
        if style == .boat {
            let delta = newValue - oldValue
            contents.state.inventory.didIncrementOnBoat(delta, consumable: contents.isConsumable)
        }
    }
}
