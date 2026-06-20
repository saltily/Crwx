//
//  Trip+Previews.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import FoundationSalt
import SwiftData

extension Trip {
    /// Generate some previews
    /// - Parameters:
    ///   - complete: How many complete previews to make
    ///   - incompletion: Whether to create a partial trip that is still active. `nil` means no partial, `0` would be brand new, `5` would be fully complete
    /// - Returns: The requested previews
    static func previews(complete: Int, incompletion: Int?) -> [Trip] {
        var trips = [Trip]()
        if complete == 1 {
            // if 1 do one a couple weeks ago
            trips.append(.preview(date: Date.now.adding(days: -14).withoutTime))
        }
        else if complete > 1 {
            // if 2 do two on same day a couple weeks ago
            let startTime = TimeInterval.random(in: 5.5.hour...12.hour)
            var d = Date.now.adding(days: -14).withoutTime.addingTimeInterval(startTime)
            let trip1 = Trip.preview(date: d, maxDuration: 4.5.hour)
            trips.append(trip1)
            let trip2 = Trip.preview(date: d.addingTimeInterval(.random(in: 20.minute...75.minute)))
            trips.append(trip2)
            if complete > 2 {
                // if 3 do two on same day a couple weeks ago, and 1 the previous month
                let previousMonth = d.monthYear - 1
                let previousMonthRange = previousMonth.range
                let randomMoment = TimeInterval.random(in: previousMonthRange.lowerBound.timeIntervalSince1970..<previousMonthRange.upperBound.timeIntervalSince1970)
                d = .init(timeIntervalSince1970: randomMoment).withoutTime
                trips.append(.preview(date: d))
                // if more than 3, then do them 1 to 21 days apart before that
                if complete > 3 {
                    (3..<complete).forEach { _ in
                        d = d.adding(days: .random(in: -21...(-1))).withoutTime
                        trips.append(.preview(date: d))
                    }
                }
            }
        }
        // then add today for incomplete
        if let incompletion {
            trips.append(.preview(date: .now, incompletion: incompletion))
        }
        // sort descending and return
        return trips.sorted { lhs, rhs in
            lhs.date > rhs.date
        }
    }
    /// Generate a single preview
    /// - Parameters:
    ///   - date: A proposed start time for the trip. If not between 0530 and 1700, a random time earlier in the day will be chosen
    ///   - incompletion: Whether to create a partial trip that is still active. `nil` means no partial, `0` would be brand new, `5` would be fully complete
    ///   - maxDuration:
    /// - Returns: The requested preview
    static func preview(date: Date = .now, incompletion: Int? = 5, maxDuration: TimeInterval = 3.hour) -> Trip {
        // establish start time, duration
        let timeRange = 5.5.hour...(20.hour - maxDuration)
        var startTime = date.timeAsInterval
        startTime = timeRange.contains(startTime) ? startTime : TimeInterval.random(in: timeRange)
        let maxDuration = 20.hour - startTime
        let duration = maxDuration < 3.hour ? TimeInterval.random(in: (maxDuration-0.5.hour)...maxDuration) : TimeInterval.random(in: 2.5.hour...maxDuration)
        let endTime = startTime + duration
        let startAt = date.withoutTime.addingTimeInterval(startTime)
        let endAt = date.withoutTime.addingTimeInterval(endTime)
        let inRange = startAt...endAt
        
        // establish opening odometer, mmg
        let startMiles = Int.random(in: 300...400)
        let mmg = Double.random(in: 5...25)
        let endMiles = startMiles + mmg.rounded
        
        // establish opening fuel, fuel used
        let startFuel = FuelSounding.random
        let maxUsable = startFuel.gallons!
        let gallonsUsed = Double.random(in: 0...maxUsable)
        let endFuel = startFuel.subtracting(gallons: gallonsUsed)
        
        // choose two locations
        let startLocation: LocationSnippet = .random
        let endLocation: LocationSnippet = .random
        
        let trip = Trip()
        guard let incompletion else { return trip }
        
        // step 1
        guard incompletion > 0 else { return trip }
        trip.update(predeparture: .preview(
            date: startAt,
            location: startLocation,
            odometer: startMiles,
            fuel: startFuel
        ))
        
        // step 2
        guard incompletion > 1 else { return trip }
        trip.update(departure: .preview(
            time: startAt,
            location: startLocation
        ))
        
        // step 3
        guard incompletion > 2 else { return trip }
        trip.update(voyagelog: .preview(in: inRange))
        
        // step 4
        guard incompletion > 3 else { return trip }
        trip.update(arrival: .preview(
            time: endAt,
            location: endLocation
        ))
        
        // step 5
        guard incompletion > 4 else { return trip }
        trip.update(postarrival: .preview(
            milesMadeGood: mmg,
            odometer: endMiles,
            fuel: endFuel
        ))
        
        return trip
    }
}

