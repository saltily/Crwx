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
        init(previous: PackedStatus) {
            self.date = .now
            self.previousStatus = previous
        }
        let date: Date
        let previousStatus: PackedStatus
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
        self.init(id: id, label: label, state: .init(status: status, due: due), configuration: configuration)
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
            if thisStepPhrase == "leave on boat" {
                return "\(thisStepPhrase.capitalized) until \(nextStepPhrase)."
            } else {
                return "\(thisStepPhrase.capitalized), then \(nextStepPhrase)."
            }
        } else {
            return "\(thisStepPhrase.capitalized)."
        }
    }
    private var thisStepPhrase: String {
        state.stepPhrase(requiresDockside: configuration.requiresDockside)
    }
    private var nextStepPhrase: String? {
        guard state.due != .never else { return nil }
        let status = state.status
        let lifecycles = configuration.lifecycle
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
