//
//  Item+State.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation

extension PackableItem {
    /// Helps me encapsulate what is ever evolving and unique about this instance.
    @Observable
    final class State: Codable, Sendable, Hashable {
        init(status: PackedStatus, due: ActionTime, inventory: Inventory, expires: Date? = nil) {
            self.status = status
            self.due = due
            self.inventory = inventory
            self.expires = expires
        }
        /// Where it currently is.
        var status: PackedStatus {
            didSet {
                inventory.shift(oldStatus: oldValue, newStatus: status)
            }
        }
        /// Means whether should be in list to advance.  Never would not be in a list.  Anytime would always be in a list.  Else will depend on today's date.  Tends to vary by lifecycle and status.
        var due: ActionTime
        var inventory: Inventory
        var expires: Date?
        func stepPhrase(requiresDockside: Bool) -> String {
            let due = due
            let status = status
            var verb = status.thisVerb
            if requiresDockside {
                verb = "\(verb) dockside"
            }
            if due == .never {
                if status == .loadedOnBoat {
                    return "leave on boat"
                } else {
                    // wait to load
                    return "wait to \(verb)"
                }
            } else {
                // load dockside anytime
                return "\(verb) \(due.summary)"
            }
        }
    }
}


extension PackableItem.State {
    static func == (lhs: PackableItem.State, rhs: PackableItem.State) -> Bool {
        lhs.status == rhs.status &&
        lhs.due == rhs.due &&
        lhs.inventory == rhs.inventory &&
        lhs.expires == rhs.expires
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(status)
        hasher.combine(due)
        hasher.combine(inventory)
        hasher.combine(expires)
    }
}
