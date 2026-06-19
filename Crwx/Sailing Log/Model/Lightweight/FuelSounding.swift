//
//  FuelSounding.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import SwiftData

struct FuelSounding: Codable, Equatable {
    var soundingId: UUID = .init()
    var inches: Double? {
        didSet {
            if let inches {
                self.gallons = inches / 22 * 50
            }
            else {
                self.gallons = 0
            }
        }
    }
    var gallons: Double?
}


// MARK: Extended
extension FuelSounding {
    var percent: Double {
        if let inches {
            return inches / 22
        }
        else if let gallons {
            return gallons / 50
        }
        return 0
    }
    func subtracting(gallons: Double) -> FuelSounding {
        if let old_gallons = self.gallons {
            var new_sounding = FuelSounding(gallons: [old_gallons - gallons, 0].max())
            new_sounding.updateInches()
            return new_sounding
        }
        return FuelSounding()
    }
    /// Duplicates this but makes sure it gets its own id
    func copy() -> FuelSounding {
        .init(soundingId: .init(), inches: inches, gallons: gallons)
    }
}


// MARK: Sounding table
extension FuelSounding {
    mutating func updateGallons() {
        if let inches {
            let percent = inches / 22
            self.gallons = percent * 50
        }
        else {
            self.gallons = nil
        }
    }
    mutating func updateInches() {
        if let gallons {
            let percent = gallons / 50
            self.inches = percent * 22
        }
        else {
            self.inches = nil
        }
    }
    init(gallons: Double?) {
        self.gallons = gallons
        self.updateInches()
    }
}


// MARK: Random preview
extension FuelSounding {
    static var random: FuelSounding {
        var sounding = FuelSounding(gallons: .random(in: 1...15))
        sounding.updateInches()
        return sounding
    }
}

// MARK: Codable
extension FuelSounding {
    enum CodingKeys: CodingKey {
        case inches, gallons, soundingId
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        soundingId = try container.decodeIfPresent(UUID.self, forKey: .soundingId) ?? .init()
        inches = try container.decodeIfPresent(Double.self, forKey: .inches)
        gallons = try container.decodeIfPresent(Double.self, forKey: .gallons)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(soundingId, forKey: .soundingId)
        try container.encodeIfPresent(inches, forKey: .inches)
        try container.encodeIfPresent(gallons, forKey: .gallons)
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
