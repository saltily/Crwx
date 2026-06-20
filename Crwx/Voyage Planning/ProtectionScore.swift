//
//  ProtectionScore.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/22/25.
//

import Foundation

struct ProtectionScore: RawRepresentable, Codable, Equatable, Identifiable, Hashable {
    var id: Int { rawValue }
    let rawValue: Int
    init?(rawValue: Int) {
        guard (0...5).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

extension ProtectionScore {
    static var allCases: [ProtectionScore] {
        (0...5).map {
            .init(rawValue: $0)!
        }.reversed()
    }
}

extension ProtectionScore {
    var description: String {
        switch rawValue {
        case 5: return "Best protection available; hurricane hole."
        case 4: return "Well protected under most conditions; good anchorage."
        case 3: return "Well protected from prevailing southwest summer winds."
        case 2: return "Reasonably protected from prevailing winds; some exposure."
        case 1: return "Exposed in 2 or more directions; OK as a temporary anchorage."
        case 0: return "No protection."
        default:
            assertionFailure()
            return "Undefined."
        }
    }
}
