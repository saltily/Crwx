//
//  Sounding.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import Foundation
import SwiftData

typealias Sounding = CurrentSchema.Sounding

extension Sounding {
    var type: T {
        get { .init(rawValue: self._type) ?? .fuel }
        set { self._type = newValue.rawValue }
    }
    var waterValue: WaterValue? {
        if let value {
            return .init(rawValue: value)
        }
        return nil
    }
    var fuelSounding: FuelSounding? {
        .init(gallons: value)
    }
}


// MARK: Fetching
extension Sounding {
    static func find(_ id: UUID?, in context: ModelContext) -> Sounding? {
        guard let id else { return nil }
        return try? context.fetchOne(#Predicate {
            $0.id == id
        })
    }
}
extension Predicate {
    static func soundings(of type: Sounding.T) -> Predicate<Sounding> {
        let i = type.rawValue
        return #Predicate<Sounding> {
            $0._type == i
        }
    }
}
extension FetchDescriptor where T == Sounding {
    static func lastSounding(of type: Sounding.T) -> FetchDescriptor<Sounding> {
        var d = FetchDescriptor(predicate: .soundings(of: type), sortBy: [.init(\.date, order: .reverse)])
        d.fetchLimit = 1
        return d
    }
}


// MARK: Type
extension Sounding {
    enum T: Int, CaseIterable {
        case fuel, water, propane, iceBox
        var title: String {
            switch self {
            case .fuel:
                "Fuel Soundings"
            case .water:
                "Water Soundings"
            case .propane:
                "Propane Inventory"
            case .iceBox:
                "Ice Box Temperatures"
            }
        }
        var name: String {
            switch self {
            case .fuel:
                "Fuel"
            case .water:
                "Water"
            case .propane:
                "Propane"
            case .iceBox:
                "Ice Box"
            }
        }
        var systemImage: String {
            switch self {
            case .fuel:
                "fuelpump"
            case .water:
                "spigot"
            case .propane:
                "flame"
            case .iceBox:
                "thermometer.snowflake"
            }
        }
        var units: String {
            switch self {
            case .fuel, .water:
                "gals"
            case .propane:
                "bottles"
            case .iceBox:
                "ºF"
            }
        }
    }
}


