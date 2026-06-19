//
//  WindSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import FoundationSalt
import WeatherKit

struct WindSnippet: Codable, Equatable {
    var direction: Double?
    var gust: Double?
    var speed: Range<Double>
}

// MARK: Extended
extension WindSnippet {
    init(direction: Double?, speed: Double..., gust: Double? = nil) {
        self.init(direction: direction, speed: speed, gust: gust)
    }
    init(direction: Double?, speed: [Double], gust: Double? = nil) {
        self.direction = direction
        self.speed = speed.count == 2 ?
            .init(uncheckedBounds: (speed[0], speed[1])) :
            .init(uncheckedBounds: (speed[0], speed[0]))
        self.gust = gust
    }
    init(apple: Wind) {
        self.init(
            direction: apple.direction.converted(to: .degrees).value,
            speed: apple.speed.converted(to: .knots).value,
            gust: apple.gust?.converted(to: .knots).value
        )
    }
    var compassDirection: CompassDirection {
        get {
            .init(cardinal: angle)
        }
        set {
            self.direction = newValue.direction?.converted(to: .degrees).value
        }
    }
    var max: Double {
        if let gust { return Swift.max(gust, speed.upperBound) }
        return speed.upperBound
    }
    var summary: String {
        var words = [compassDirection.string]
        let min = speed.lowerBound.rounded
        let max = gust?.rounded ?? speed.upperBound.rounded
        if min == max {
            words.append(min.string)
        }
        else {
            words.append("\(min)-\(max)")
        }
        return words.joined(separator: " ")
    }
    var summaryWithGusts: String {
        var words = [compassDirection.string]
        let min = speed.lowerBound.rounded
        let max = speed.upperBound.rounded
        if min == max {
            words.append(min.string)
        }
        else {
            words.append("\(min)-\(max)")
        }
        if let gust {
            words.append("G\(gust.rounded)")
        }
        return words.joined(separator: " ")
    }
    var speedSummaryWithGusts: String {
        var words = [String]()
        let min = speed.lowerBound.rounded
        let max = speed.upperBound.rounded
        if min == max {
            words.append(min.string)
        }
        else {
            words.append("\(min)-\(max)")
        }
        if let gust {
            words.append("G\(gust.rounded)")
        }
        return words.joined(separator: " ")
    }
    var angle: Measurement<UnitAngle>? {
        guard let direction else { return nil }
        return .init(value: direction, unit: .degrees)
    }
}


// MARK: Preview
extension Array where Element == WindSnippet {
    static var random: Self {
        // usually one wind direction, occasionally two
        let windCount = [1,1,1,1,1,1,1,1,1,1,1,1,1,2].randomElement()!
        return (0..<windCount).map { _ in
            WindSnippet.random
        }
    }
    var summary: String {
        self.map({
            $0.summary
        }).joined(separator: ", ")
    }
    var summaryWithGusts: String {
        self.map({
            $0.summaryWithGusts
        }).joined(separator: ", ")
    }
    var angles: [Measurement<UnitAngle>] {
        self.compactMap {
            $0.angle
        }.set.array
    }
    var directions: Set<CompassDirection> {
        self.reduce(into: []) { partialResult, wind in
            partialResult.insert(wind.compassDirection)
        }
    }
    func max(_ direction: CompassDirection) -> Double? {
        self.filter {
            $0.compassDirection == direction
        }.map {
            $0.max
        }.max()
    }
}
extension WindSnippet {
    static var random: WindSnippet {
        let compass = CompassDirection.randomElement()
        // let's snap to 5's in a range of 5 to 25
        let low = Int.random(in: 1...4)
        let high = low + Int.random(in: 0...1)
        let gust: Int?
        if high > 1 {
            let gustDifferential = Int.random(in: 0...2)
            if gustDifferential > 0 {
                gust = high + gustDifferential
            }
            else {
                gust = nil
            }
        }
        else {
            gust = nil
        }
        return WindSnippet(
            direction: compass.direction?.converted(to: .degrees).value,
            speed: 5.0 * low.double, 5.0 * high.double,
            gust: gust != nil ? 5.0 * gust!.double : nil
        )
    }
}

// MARK: Codable
extension WindSnippet {
    enum CodingKeys: CodingKey {
        case direction, gust, speed
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        direction = try container.decodeIfPresent(Double.self, forKey: .direction)
        gust = try container.decodeIfPresent(Double.self, forKey: .gust)
        speed = try container.decode(Range<Double>.self, forKey: .speed)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(direction, forKey: .direction)
        try container.encodeIfPresent(gust, forKey: .gust)
        try container.encode(speed, forKey: .speed)
    }
}
