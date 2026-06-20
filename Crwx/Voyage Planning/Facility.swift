//
//  Facility.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/22/25.
//

import Foundation

struct Facilities: OptionSet, Codable {
    var rawValue: UInt16
    static var empty: Facilities {
        .init(rawValue: 0)
    }
    static let fuel = Facilities(rawValue: 1 << Facility.fuel.rawValue)
    static let water = Facilities(rawValue: 1 << Facility.water.rawValue)
    static let repairs = Facilities(rawValue: 1 << Facility.repairs.rawValue)
    static let mooringsOrSlips = Facilities(rawValue: 1 << Facility.mooringsOrSlips.rawValue)
    static let groceries = Facilities(rawValue: 1 << Facility.groceries.rawValue)
    static let laundry = Facilities(rawValue: 1 << Facility.laundry.rawValue)
    static let shower = Facilities(rawValue: 1 << Facility.shower.rawValue)
    static let restaurants = Facilities(rawValue: 1 << Facility.restaurants.rawValue)
    subscript(facility: Facility) -> Bool {
        get {
            self.contains(facility.option)
        }
        set {
            if newValue {
                self.insert(facility.option)
            } else {
                self.remove(facility.option)
            }
        }
    }
    var facilities: [Facility] {
        Facility.allCases.filter {
            self.contains($0.option)
        }
    }
}

enum Facility: Int, Codable, Identifiable, CaseIterable {
    var id: Int { rawValue }
    case fuel, water, repairs, mooringsOrSlips, groceries, laundry, shower, restaurants
    var option: Facilities {
        Facilities(rawValue: 1 << rawValue)
    }
}

extension Facility {
    var description: String {
        switch self {
        case .fuel:
            "Fuel (gas, diesel, or both)"
        case .water:
            "Water"
        case .repairs:
            "Repairs"
        case .mooringsOrSlips:
            "Moorings and/or Slips"
        case .groceries:
            "Groceries (within half mile)"
        case .laundry:
            "Laundromat"
        case .shower:
            "Shower"
        case .restaurants:
            "Restaurant and/or Takeout"
        }
    }
    var systemImage: String {
        switch self {
        case .fuel:
            "fuelpump"
        case .water:
            "spigot"
        case .repairs:
            "wrench.adjustable"
        case .mooringsOrSlips:
            "parkingsign.square"
        case .groceries:
            "bag"
        case .laundry:
            "tshirt"
        case .shower:
            "shower"
        case .restaurants:
            "fork.knife.circle"
        }
    }
}
