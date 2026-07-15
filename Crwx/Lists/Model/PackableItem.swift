//
//  PackableItem.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import Foundation

@Observable
final class PackableItem: Codable, Sendable, Identifiable {
    var id: UUID
    var label: String
    init(_ label: String, id: UUID = .init()) {
        self.id = id
        self.label = label
    }
}
extension PackableItem: Hashable {
    static func == (lhs: PackableItem, rhs: PackableItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.label == rhs.label
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(label)
    }
}


extension PackableItem: ExpressibleByStringLiteral {
    convenience init(stringLiteral value: String) {
        self.init(value)
    }
}
