//
//  TideSnapshotSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/9/24.
//

import Foundation
import WxSalt
import FoundationSalt

struct TideSnapshotSnippet: Codable, Equatable {
    var date: Date
    var height: Double
    let movement: TideMovement
    let percentIn: Double
    let nextTide: TidePredictionSnippet? // make !
    var station: TideStationSnippet? // make !
}

// MARK: Extending
extension TideSnapshotSnippet {
    var predictedCurrent: String {
        // slack before
        // start of
        // some
        // ebb|flood
        // strong
        if percentIn >= 0.95 {
            switch movement {
            case .standingHi: return "start of ebb"
            case .rising: return "slack before ebb"
            default: return "some ebb"
            }
        }
        else if percentIn <= 0.05 {
            switch movement {
            case .standingLo: return "start of flood"
            case .falling: return "slack before flood"
            default: return "some flood"
            }
        }
        else {
            switch movement {
            case .standingHi: return "start of ebb"
            case .standingLo: return "start of flood"
            case .rising:
                // consider the max to be around 47%
                let distanceFromMax = (percentIn - 0.47).magnitude
                if distanceFromMax <= 0.13 {
                    return "strong flood"
                }
                else if distanceFromMax > 0.28 {
                    return "some flood"
                }
                else {
                    return "flood"
                }
            case .falling:
                // consider the max to be around 53%
                let distanceFromMax = (percentIn - 0.53).magnitude
                if distanceFromMax <= 0.13 {
                    return "strong ebb"
                }
                else if distanceFromMax > 0.28 {
                    return "some ebb"
                }
                else {
                    return "ebb"
                }
            }
        }
    }
}


// MARK: Preview
extension TideSnapshotSnippet {
    static var random: TideSnapshotSnippet {
        let station = TideStationSnippet.random
        return TideSnapshotSnippet(
            date: .now,
            height: .random(in: -1...13),
            movement: .randomElement(),
            percentIn: .random(in: 0...1),
            nextTide: .init(
                date: .now.addingTimeInterval(.random(in: 0...6.hour)),
                height: .random(in: -1...13),
                isHi: [true,false].randomElement()!,
                station: station),
            station: station
        )
    }
}


// MARK: Make from tide snapshot
extension TideSnapshot {
    func snippet(station: TideStationSnippet) -> TideSnapshotSnippet {
        .init(
            date: self.date,
            height: self.height.converted(to: .feet).value,
            movement: self.movement,
            percentIn: self.percentIn,
            nextTide: self.nextTide.snippet(station: station),
            station: station
        )
    }
}


// MARK: Codable
extension TideSnapshotSnippet {
    enum CodingKeys: CodingKey {
        case date, height, movement, percentIn, nextTide, station
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        height = try container.decode(Double.self, forKey: .height)
        movement = try container.decode(TideMovement.self, forKey: .movement)
        percentIn = try container.decode(Double.self, forKey: .percentIn)
        nextTide = try container.decodeIfPresent(TidePredictionSnippet.self, forKey: .nextTide)
        station = try container.decodeIfPresent(TideStationSnippet.self, forKey: .station)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(height, forKey: .height)
        try container.encode(movement, forKey: .movement)
        try container.encode(percentIn, forKey: .percentIn)
        try container.encodeIfPresent(nextTide, forKey: .nextTide)
        try container.encodeIfPresent(station, forKey: .station)
    }
}
