//
//  CoastalRegion.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import Foundation
import FoundationSalt

/// Divided at the offshore hubs.
///
enum CoastalRegion: String, CaseIterable, Identifiable, Comparable {
    var id: String { rawValue }
    // west of Bass Harbor Bar
    case BlueHill = "Blue Hill"
    // Bass Harbor Bar to Schoodic
    case Frenchman = "Frenchman Bay"
    // Schoodic to Petit Manan
    case Schoodic
    // Petit Manan to Pond Point
    case Addison
    // Pond Point to Cross Island
    case Home
    // east of Cross Island
    case Cutler
    // something new way out of bounds
    case Unknown
}

extension CoastalRegion {
    init(_ point: any Mappable) {
        let long = point.coordinate.longitude
        if long < -68.60 {
            self = .Unknown
        } else if long < -68.33 {
            self = .BlueHill
        } else if long < -68.05 {
            self = .Frenchman
        } else if long < -67.88 {
            self = .Schoodic
        } else if long < -67.60 {
            self = .Addison
        } else if long < -67.26 {
            self = .Home
        } else if long < -66.94 {
            self = .Cutler
        } else {
            self = .Unknown
        }
    }
    var easternLongitude: Double {
        switch self {
        case .BlueHill:
            -68.33
        case .Frenchman:
            -68.05
        case .Schoodic:
            -67.88
        case .Addison:
            -67.60
        case .Home:
            -67.26
        case .Cutler:
            -66.94
        case .Unknown:
            -68.60
        }
    }
    static func < (lhs: Self, rhs: Self) -> Bool {
        compare(lhs: lhs, rhs: rhs, using: .init(\.easternLongitude)) == .orderedAscending
    }
}
extension Mappable {
    var coastalRegion: CoastalRegion {
        .init(self)
    }
}

extension Array where Element: Mappable {
    func coastalRegion(_ r: CoastalRegion?) -> Self {
        guard let r else { return self }
        return self.filter {
            $0.coastalRegion == r
        }
    }
}
