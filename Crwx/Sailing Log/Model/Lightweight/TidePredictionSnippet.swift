//
//  TidePredictionSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import WxSalt
import FoundationSalt

struct TidePredictionSnippet: Codable, Equatable {
    var date: Date
    var height: Double
    var isHi: Bool
    var station: TideStationSnippet? // make !
}

// MARK: Comparable
extension TidePredictionSnippet: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.date < rhs.date
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.date == rhs.date &&
        lhs.isHi == rhs.isHi &&
        lhs.height == rhs.height &&
        lhs.station?.id == rhs.station?.id
    }
}

// MARK: Preview
extension Array where Element == TidePredictionSnippet {
    static func random(on day: Date) -> Self {
        var predictions: [TidePredictionSnippet] = []
        let station: TideStationSnippet = .random
        // heights
        let rangeOne = Double.random(in: 8.5...15)
        let rangeTwo = rangeOne * .random(in: 0.9...1.1)
        let lowOne = 6.5 - (rangeOne/2)
        let hiOne = 6.5 + (rangeOne/2)
        let lowTwo = 6.5 - (rangeTwo/2)
        let hiTwo = 6.5 + (rangeTwo/2)
        // 1st tide
        var time = TimeInterval.random(in: 0...(6.hour))
        var isHi = [true, false].randomElement()!
        predictions.append(.init(
            date: day.withoutTime.addingTimeInterval(time),
            height: isHi ? hiOne : lowOne,
            isHi: isHi,
            station: station
        ))
        // 2nd tide
        time = time + .random(in: 6.1.hour...6.2.hour)
        isHi = !isHi
        predictions.append(.init(
            date: day.withoutTime.addingTimeInterval(time),
            height: isHi ? hiOne : lowOne,
            isHi: isHi,
            station: station
        ))
        // 3rd tide
        time = time + .random(in: 6.1.hour...6.2.hour)
        isHi = !isHi
        predictions.append(.init(
            date: day.withoutTime.addingTimeInterval(time),
            height: isHi ? hiTwo : lowTwo,
            isHi: isHi,
            station: station
        ))
        // 4th tide
        time = time + .random(in: 6.1.hour...6.2.hour)
        if time < 24.hour {
            isHi = !isHi
            predictions.append(.init(
                date: day.withoutTime.addingTimeInterval(time),
                height: isHi ? hiTwo : lowTwo,
                isHi: isHi,
                station: station
            ))
        }
        return predictions
    }
}


// MARK: Make from regular predictions
extension TidePrediction {
    func snippet(station: TideStationSnippet) -> TidePredictionSnippet {
        .init(date: self.date, height: self.height.converted(to: .feet).value, isHi: self.isHi, station: station)
    }
}
extension [TidePrediction] {
    func snippets(station: TideStationSnippet) -> [TidePredictionSnippet] {
        self.map {
            $0.snippet(station: station)
        }
    }
}
extension [TidePredictionSnippet] {
    /// Convert these tide predictions into set of minutes that are flooding.
    ///
    /// Note these are by number of seconds, so not consecutive.
    func minutesFlooding(during: Range<Date>) -> Set<Int> {
        guard let first = self.first else { return [] }
        var floodingStamps = Set<Int>()
        var currentDate = first.date.withoutTime
        var reader = self.reader
        var prediction = first
        while !reader.didReachEnd {
            prediction = reader.read()
            if prediction.date.subtractingTimeInterval(20.minute) > currentDate {
                while currentDate < prediction.date.subtractingTimeInterval(20.minute) {
                    if prediction.isHi {
                        floodingStamps.insert(currentDate.timeIntervalSinceReferenceDate.rounded(.Minute, .down).int)
                    }
                    currentDate = currentDate.addingTimeInterval(.Minute)
                }
            }
        }
        if !prediction.isHi, prediction.date.withoutTime == first.date.withoutTime {
            while currentDate < prediction.date.withoutTime.tomorrow {
                floodingStamps.insert(currentDate.timeIntervalSinceReferenceDate.rounded(.Minute, .down).int)
                currentDate = currentDate.addingTimeInterval(.Minute)
            }
        }
        // convert the timespan into a set of timestamps for each minute
        var duringStamps = Set<Int>()
        currentDate = during.lowerBound
        while currentDate < during.upperBound {
            duringStamps.insert(currentDate.timeIntervalSinceReferenceDate.rounded(.Minute, .down).int)
            currentDate = currentDate.addingTimeInterval(.Minute)
        }
        let intersection = duringStamps.intersection(floodingStamps)
        return intersection
    }
    /// Assumes that these predictions and the supplied range are all within the same 24 hours
    func percentFlooding(during: Range<Date>) -> Double? {
        let minutesFlooding = self.minutesFlooding(during: during)
        guard !minutesFlooding.isEmpty else { return nil }
        let totalMinutes = during.duration / .Minute
        let percentage = minutesFlooding.count.double / totalMinutes
        return percentage
    }
}


// MARK: Codable
extension TidePredictionSnippet {
    enum CodingKeys: CodingKey {
        case date, height, isHi, station
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        height = try container.decode(Double.self, forKey: .height)
        isHi = try container.decode(Bool.self, forKey: .isHi)
        station = try container.decodeIfPresent(TideStationSnippet.self, forKey: .station)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(height, forKey: .height)
        try container.encode(isHi, forKey: .isHi)
        try container.encodeIfPresent(station, forKey: .station)
    }
}
