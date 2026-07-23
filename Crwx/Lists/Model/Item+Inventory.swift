//
//  Item+Inventory.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/22/26.
//

import Foundation

extension PackableItem {
    struct Inventory {
        var includeInBoatInventory: Bool
        var includeInShoreInventory: Bool
        var quantityOnBoat: Double
        var quantityOnShore: Double
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
}
