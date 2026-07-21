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
    var lastInventoried: Date?
    init(id: UUID, label: String, state: State, configuration: Configuration, lastInventoried: Date? = nil) {
        self.id = id
        self.created = .now
        self.label = label
        self.state = state
        self.configuration = configuration
        self.lastInventoried = lastInventoried
    }
}

extension PackableItem: Hashable {
    static func == (lhs: PackableItem, rhs: PackableItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.label == rhs.label &&
        lhs.state == rhs.state &&
        lhs.configuration == rhs.configuration &&
        lhs.lastInventoried == rhs.lastInventoried
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(label)
        hasher.combine(state)
        hasher.combine(configuration)
        hasher.combine(lastInventoried)
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
