//
//  Item+Inventory.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/22/26.
//

import Foundation
import FoundationSalt

extension PackableItem {
    struct Inventory: Codable, Sendable, Hashable {
        var includeInBoatInventory: Bool = true
        var includeInShoreInventory: Bool = false
        var quantityOnBoat: Double = 0
        var quantityOnShore: Double = 1
    }
}

extension PackableItem.Inventory {
    static var noneInInventory: Self {
        .init(includeInBoatInventory: true, includeInShoreInventory: true, quantityOnBoat: 0, quantityOnShore: 0)
    }
    static var onHandToTakeOut: Self {
        .init(includeInBoatInventory: true, includeInShoreInventory: false, quantityOnBoat: 0, quantityOnShore: 1)
    }
    static var loadedOnBoat: Self {
        .init(includeInBoatInventory: true, includeInShoreInventory: false, quantityOnBoat: 1, quantityOnShore: 0)
    }
}

extension PackableItem.Inventory {
    /// Also needs to know if consumable, perishable, expirable.
    mutating func incrementOnBoat(_ i: Double = 1, consumable: Bool = false) {
        quantityOnBoat = max(0, quantityOnBoat + i)
        didIncrementOnBoat(i, consumable: consumable)
    }
    /// If manually changed value in interface, then can apply this method to adjust quantity on shore as appropriate.
    mutating func didIncrementOnBoat(_ i: Double, consumable: Bool) {
        // if increasing, assume we're taking from shore
        if i > 0 {
            quantityOnShore = max(0, quantityOnShore - i)
        }
        // if decreasing and not consumable, assume we're giving to shore
        else if i < 0, !consumable {
            quantityOnShore = max(0, quantityOnShore - i)
        }
        // else if decreasing and consumable, doesn't effect shore
    }
    mutating func decrementOnBoat(consumable: Bool) {
        incrementOnBoat(-1, consumable: consumable)
    }
    mutating func incrementOnShore(_ i: Double = 1) {
        quantityOnShore = max(0, quantityOnShore + i)
    }
    mutating func decrementOnShore() {
        incrementOnShore(-1)
    }
    mutating func shift(oldStatus: PackedStatus, newStatus: PackedStatus) {
        switch oldStatus {
        case .purchase, .prep:
            // we bought one and adding to shore or boat
            if newStatus == .loadedOnBoat {
                quantityOnBoat += 1
            } else if newStatus.isIn(.shoreOnHand, .packed) {
                quantityOnShore += 1
            }
        case .shoreOnHand, .packed:
            // we moved from shore to boat
            if newStatus == .loadedOnBoat {
                incrementOnBoat() // doesn't matter if consumable and will decrement on shore
            }
        case .loadedOnBoat:
            // we took it off the boat
            if newStatus.isIn(.shoreOnHand, .packed) {
                decrementOnBoat(consumable: false) // not consumable else will not add to shore
            }
        }
    }
    func rollback(from newStatus: PackedStatus, to oldStatus: PackedStatus) -> PackableItem.Inventory {
        var copy = self
        switch newStatus {
        case .loadedOnBoat:
            // going back to on hand, need to move item off the boat
            copy.decrementOnBoat(consumable: false)
        case .shoreOnHand:
            // depends on the previous
            if oldStatus.isIn(.purchase, .prep) {
                copy.decrementOnShore()
            } else if oldStatus == .loadedOnBoat {
                copy.incrementOnBoat()
            }
        default:
            // nothing  These are never in a checked state
            return copy
        }
        return copy
    }
}
