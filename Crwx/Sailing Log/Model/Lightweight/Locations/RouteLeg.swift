//
//  RouteLeg.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/8/25.
//

import Foundation
import FoundationSalt

struct RouteLeg: Codable {
    let start: LocationSnippet
    let end: LocationSnippet
    let bearing: Measurement<UnitAngle>
    let distance: Measurement<UnitLength>
}

extension RouteLeg {
    init?(start: LocationSnippet?, end: LocationSnippet?) {
        guard let start, let end else { return nil }
        self.start = start
        self.end = end
        bearing = end.bearing(from: start)
        distance = start.distance(to: end)
    }
    var nauticalMiles: Double {
        distance.converted(to: .nauticalMiles).value
    }
    var isZero: Bool {
        nauticalMiles ~= 0
    }
}
