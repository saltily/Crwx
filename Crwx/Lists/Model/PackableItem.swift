//
//  PackableItem.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import Foundation
import FoundationSalt

@Observable
final class PackableItem: Codable, Sendable, Identifiable {
    var id: UUID
    /// So we can sort by date added.
    var created: Date
    var label: String
    var state: State
    var configuration: Configuration = .init()
    /// To include recently shifted stuff in previous lists.
    var lastShift: Shift?
    /// To show in the inventory when this was last done.
    var lastInventoried: Date?
    init(id: UUID, label: String, state: State, configuration: Configuration, lastInventoried: Date? = nil) {
        self.id = id
        self.created = .now
        self.label = label
        self.state = state
        self.configuration = configuration
        self.lastInventoried = lastInventoried
    }
    struct Shift: Codable, Sendable, Hashable {
        init(previous: PackedStatus, previousDue: ActionTime) {
            self.date = .now
            self.previousStatus = previous
            self.previousDue = previousDue
        }
        let date: Date
        let previousStatus: PackedStatus
        let previousDue: ActionTime
        func verbed(new: PackedStatus) -> String {
            switch previousStatus {
            case .purchase: "Purchased"
            case .prep: "Prepared"
            case .shoreOnHand:
                if new == .packed {
                    "Packed"
                } else {
                    "Loaded"
                }
            case .packed: "Loaded"
            case .loadedOnBoat: "Offloaded"
            }
        }
    }
}

extension PackableItem {
    func update(status newValue: PackedStatus) {
        let oldValue = self.state.status
        guard newValue != oldValue else { return }
        let oldDue = self.state.due
        let lifecycles = configuration.lifecycle
        // once loaded, keep it there for now unless fleeting or daysail (briefest known time)
        if newValue == .loadedOnBoat {
            if lifecycles.contains(.fleeting) ||
                lifecycles.contains(.daysail)
            {
                self.state.due = .anytime
            } else {
                self.state.due = .never
            }
        }
        // if coming off of the boat, we keep it ashore for now
        else if oldValue == .loadedOnBoat {
            self.state.due = .never
        }
        // else can keep the same due date for advancement
        self.state.status = newValue
        self.lastShift = .init(previous: oldValue, previousDue: oldDue)
    }
    var isDue: Bool {
        self.state.due.isDue
    }
    var isConsumable: Bool {
        self.state.expires != nil ||
        self.configuration.lifecycle.contains(.perishable) ||
        self.configuration.lifecycle.contains(.consumable)
    }
}

extension PackableItem: Hashable {
    static func == (lhs: PackableItem, rhs: PackableItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.label == rhs.label &&
        lhs.state == rhs.state &&
        lhs.configuration == rhs.configuration &&
        lhs.lastInventoried == rhs.lastInventoried &&
        lhs.lastShift == rhs.lastShift
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(label)
        hasher.combine(state)
        hasher.combine(configuration)
        hasher.combine(lastInventoried)
        hasher.combine(lastShift)
    }
}


extension PackableItem: ExpressibleByStringLiteral {
    /// This sets up with defaults including saying it is on shore and ready to go to the boat anytime.
    convenience init(stringLiteral value: String) {
        self.init(value)
    }
    /// So you can setup the current location and when to shift it.
    /// You can also reuse basic configurations for multiple items.
    convenience init(_ label: String, id: UUID = .init(), status: PackedStatus = .shoreOnHand, due: ActionTime = .anytime, configuration: Configuration = .init()) {
        self.init(id: id, label: label, state: .init(status: status, due: due, inventory: status.defaultInventory), configuration: configuration)
    }
}


// MARK: Summarise
extension PackableItem {
    private func describe(date: Date) -> String {
        date.formatted(.relative(presentation: .named))
    }
    var createdSentence: String {
        "Created \(describe(date: created))."
    }
    var shiftedSentence: String? {
        guard let lastShift else { return nil }
        return "\(lastShift.verbed(new: state.status)) \(describe(date: lastShift.date))."
    }
    var inventoriedSentence: String? {
        guard let lastInventoried else { return nil }
        return "Inventoried \(describe(date: lastInventoried))."
    }
    /// Combines status, due, and lifecycle to describe what will happen when we check it off, and what will happen to it next after that.
    var stepsSummary: String {
        let thisStepPhrase = thisStepPhrase
        if let nextStepPhrase {
            if state.due == .never {
                return "\(thisStepPhrase.capitalised) \(nextStepPhrase)."
            } else {
                return "\(thisStepPhrase.capitalised), then \(nextStepPhrase)."
            }
        } else {
            return "\(thisStepPhrase.capitalised)."
        }
    }
    private var thisStepPhrase: String {
        state.stepPhrase(requiresDockside: configuration.requiresDockside)
    }
    private var nextStepPhrase: String? {
        let status = state.status
        let lifecycles = configuration.lifecycle
        if state.due == .never {
            switch status {
            case .loadedOnBoat:
                // Leave on boat…
                if lifecycles.contains(.daysail) {
                    return "until end of daysail"
                } else if lifecycles.contains(.cruise) {
                    return "until end of cruise"
                } else if lifecycles.contains(.project) {
                    return "until project is complete"
                } else if lifecycles.contains(.seasonal) {
                    return "until end of season"
                } else {
                    return nil
                }
            case .shoreOnHand:
                // Wait to load…
                if lifecycles.contains(.daysail) {
                    return "for next daysail"
                } else if lifecycles.contains(.cruise) {
                    return "for next cruise"
                } else if lifecycles.contains(.seasonal) {
                    return "for next season"
                } else {
                    return nil
                }
            default:
                return nil
            }
        }
        guard state.due != .never else { return nil }
        switch status {
        case .purchase, .prep:
            return "load"
        case .packed, .shoreOnHand:
            // when to bring it back
            if lifecycles.contains(.fleeting) {
                return "offload anytime"
            } else if lifecycles.contains(.daysail) {
                return "offload at end of daysail"
            } else if lifecycles.contains(.cruise) {
                return "offload at end of cruise"
            } else if lifecycles.contains(.project) {
                return "leave aboard until project is complete"
            } else if lifecycles.contains(.seasonal) {
                return "leave aboard until end of season"
            } else {
                return "leave aboard"
            }
        case .loadedOnBoat:
            // when to take back out
            if lifecycles.contains(.daysail) {
                return "pack for next daysail"
            } else if lifecycles.contains(.cruise) {
                return "pack for next cruise"
            } else if lifecycles.contains(.seasonal) {
                return "load up next season"
            } else {
                return nil
            }
        }
    }
}


// MARK: Is In Inventory
extension PackableItem {
    func isInInventory(_ style: InventoryListItem.Style) -> Bool {
        switch style {
        case .boat:
            return state.inventory.includeInBoatInventory ||
            state.inventory.quantityOnBoat > 0
        case .shore:
            return state.inventory.includeInShoreInventory ||
            state.inventory.quantityOnShore > 0
        }
    }
    func appearsInPackingLists() -> Bool {
        PackingFilter.all.map({
            $0.appearsInList(self)
        }).reduce(false) { partialResult, v in
            partialResult || v
        }
    }
    var isStray: Bool {
        !appearsInPackingLists() &&
        !isInInventory(.boat) &&
        !isInInventory(.shore)
    }
}
