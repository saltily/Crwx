//
//  WaveSnippet.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/30/25.
//

import Foundation
import FoundationSalt

struct WaveSnippet: Codable, Equatable {
    /// In degrees
    var direction: Double?
    /// In feet (max height)
    var height: Double?
    /// In seconds
    var period: TimeInterval?
}

extension WaveSnippet {
    var compassDirection: CompassDirection {
        get {
            .init(cardinal: angle)
        }
        set {
            self.direction = newValue.direction?.converted(to: .degrees).value
        }
    }
    var angle: Measurement<UnitAngle>? {
        guard let direction else { return nil }
        return .init(value: direction, unit: .degrees)
    }
    var summary: String {
        var words: [String] = []
        if direction != nil {
            words.append(compassDirection.abbreviation)
        }
        if let height {
            words.append("\(height.rounded)")
        }
        if let period {
            words.append("at \(period.rounded)")
        }
        return words.joined(separator: " ")
    }
}
extension [WaveSnippet] {
    var summary: String {
        self.map {
            $0.summary
        }.joined(separator: ", ")
    }
    var directions: Set<CompassDirection> {
        self.reduce(into: []) { partialResult, wave in
            partialResult.insert(wave.compassDirection)
        }
    }
    func max(_ direction: CompassDirection) -> Double? {
        self.filter {
            $0.compassDirection == direction
        }.compactMap {
            $0.height
        }.max()
    }
}
