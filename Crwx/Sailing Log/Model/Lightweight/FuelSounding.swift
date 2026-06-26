//
//  FuelSounding.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import SwiftData

struct FuelSounding: nonisolated Codable, Equatable {
    var soundingId: UUID = .init()
    var inches: Double?
    var gallons: Double? {
        get {
            guard let inches else { return nil }
            return inches / 22 * 50
        }
        set {
            if let newValue {
                inches = newValue / 50 * 22
            } else {
                inches = nil
            }
        }
    }
}


// MARK: Extended
extension FuelSounding {
    var percent: Double {
        if let inches {
            return inches / 22
        }
        return 0
    }
    func subtracting(gallons: Double) -> FuelSounding {
        if let old_gallons = self.gallons {
            return FuelSounding(gallons: [old_gallons - gallons, 0].max())
        }
        return FuelSounding()
    }
    /// Duplicates this but makes sure it gets its own id
    func copy() -> FuelSounding {
        .init(soundingId: .init(), inches: inches)
    }
}


// MARK: Sounding table
extension FuelSounding {
    init(gallons: Double?) {
        self.gallons = gallons
    }
    init(inches: Double?) {
        self.inches = inches
    }
}


// MARK: Random preview
extension FuelSounding {
    static var random: FuelSounding {
        .init(gallons: .random(in: 1...15))
    }
}

// MARK: Codable
extension FuelSounding {
    enum CodingKeys: CodingKey {
        case inches, soundingId
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        soundingId = try container.decodeIfPresent(UUID.self, forKey: .soundingId) ?? .init()
        inches = try container.decodeIfPresent(Double.self, forKey: .inches)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(soundingId, forKey: .soundingId)
        try container.encodeIfPresent(inches, forKey: .inches)
    }
}


// MARK: Save
extension FuelSounding {
    mutating func save(for date: Date, in context: ModelContext) {
        if let sounding = Sounding.find(soundingId, in: context) {
            sounding.value = gallons
        } else {
            let sounding = Sounding(date: date, value: gallons, note: "", _type: Sounding.T.fuel.rawValue)
            sounding.id = self.soundingId
            context.insert(sounding)
        }
    }
}
