//
//  PackedCategory.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation

/// The idea is to help organise things into sections when looking at stuff like inventory and packing.
enum PackedCategory: RawRepresentable, Codable, Sendable, Hashable {
    case food, freezable, coldStorage, drinks
    case safetyEquipment, cleaningSupplies, electronics, tools
    case filters, fluids, spareParts, boatswain
    case linens, outerwear, clothing, toiletries, entertainment
    case kitchenware, paperProducts, energy
    case library, navigation
    case custom(String)
}

extension PackedCategory: CustomStringConvertible {
    var description: String { rawValue }
    var rawValue: String {
        switch self {
        case .food: "food"
        case .freezable: "freezable"
        case .coldStorage: "cold storage"
        case .drinks: "drinks"
        case .safetyEquipment: "safety equipment"
        case .cleaningSupplies: "cleaning supplies"
        case .electronics: "electronics"
        case .tools: "tools"
        case .filters: "filters"
        case .fluids: "fluids"
        case .spareParts: "spare parts"
        case .boatswain: "boatswain"
        case .linens: "linens"
        case .energy: "energy"
        case .outerwear: "outerwear"
        case .clothing: "clothing"
        case .toiletries: "toiletries"
        case .entertainment: "entertainment"
        case .kitchenware: "kitchenware"
        case .paperProducts: "paper products"
        case .library: "library"
        case .navigation: "navigation"
        case .custom(let string): string
        }
    }
    init(rawValue: String) {
        if let match = Self.allCases.first(where: {
            $0.rawValue == rawValue.lowercased()
        }) {
            self = match
        } else {
            self = .custom(rawValue)
        }
    }
    static var allCases: [PackedCategory] {
        [
            .food, .freezable, .coldStorage, .drinks,
            .safetyEquipment, .cleaningSupplies, .electronics, .tools,
            .filters, .fluids, .spareParts, .boatswain,
            .linens, .outerwear, .clothing, .toiletries, .entertainment,
            .kitchenware, .paperProducts, .energy,
            .library, .navigation
        ]
    }
    var isCustom: Bool {
        switch self {
        case .custom: true
        default: false
        }
    }
}


// MARK: Codable
extension PackedCategory {
    enum CodingKeys: CodingKey {
        case rawValue
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(String.self, forKey: .rawValue)
        self = .init(rawValue: rawValue)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawValue, forKey: .rawValue)
    }
}
