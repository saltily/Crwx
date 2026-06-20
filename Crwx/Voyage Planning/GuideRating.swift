//
//  GuideRating.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/22/25.
//

import Foundation

struct GuideRating: RawRepresentable, Codable, Identifiable, Equatable {
    var id: Int { rawValue }
    let rawValue: Int
    init?(rawValue: Int) {
        guard (1...5).contains(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

extension GuideRating {
    var percentage: Double {
        rawValue.double / 5
    }
    init?(percentage: Double?) {
        guard let percentage else { return nil }
        self.init(rawValue: (percentage * 5).rounded)
    }
}

extension GuideRating {
    var description: String {
        switch rawValue {
        case 5: return "Both beautiful and interesting. Not to be missed."
        case 4: return "Very attractive or interesting. Worth going out of your way."
        case 3: return "Attractive or interesting."
        case 2: return "Nothing special by Maine standards, but still pleasant."
        case 1: return "Not very attractive."
        default:
            assertionFailure()
            return "Undefined."
        }
    }
}
