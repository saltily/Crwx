//
//  ImportSource.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/20/25.
//

import Foundation

enum ImportSource: Equatable {
    case garmin, gaia, rosepoint
    case unknown(String)
}

extension ImportSource {
    init?(rawValue: String?) {
        guard let rawValue,
              !rawValue.isEmpty
        else { return nil }
        if rawValue.contains("echoMAP") {
            self = .garmin
        } else if rawValue.contains("Gaia") {
            self = .gaia
        } else if rawValue == "RosePoint" {
            self = .rosepoint
        } else {
            self = .unknown(rawValue)
        }
    }
    var systemImage: String {
        switch self {
        case .garmin:
//            return "sailboat"
            return "antenna.radiowaves.left.and.right"
//            return "globe"
        case .gaia:
            return "figure.hiking"
        case .rosepoint:
            return "safari"
        case .unknown:
            return "questionmark"
        }
    }
}
