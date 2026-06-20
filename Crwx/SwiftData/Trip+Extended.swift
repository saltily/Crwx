//
//  Trip+Extended.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation

extension Trip {
    var duration: TimeInterval? {
        guard let start = departureTime,
              let end = arrivalTime
        else { return nil }
        return end.timeIntervalSince(start)
    }
    var percentComplete: Double {
        var stages: [Double] = []

        // stage 1: 7 points
        var accumulatedPoints = 0.0
        if let _ = odometerStart { accumulatedPoints += 1 }
        if let _ = fuelStart { accumulatedPoints += 1 }
        if !tidePredictions.isEmpty { accumulatedPoints += 1 }
        if let _ = localForecast { accumulatedPoints += 1 }
        if let _ = marineForecast { accumulatedPoints += 1 }
        if let _ = buoyObservation { accumulatedPoints += 1 }
        if let _ = departureLocation { accumulatedPoints += 1 }
        stages.append(accumulatedPoints / 7.0)
        
        // stage 2: 5 points
        accumulatedPoints = 0.0
        if let _ = departureTime { accumulatedPoints += 1 }
        if let _ = departureWindSpeed { accumulatedPoints += 1 }
        if let _ = departureTide { accumulatedPoints += 1 }
        if let _ = departureDepth { accumulatedPoints += 1 }
        if !departureTidalCurrent.isEmpty { accumulatedPoints += 1 }
//        if let _ = departureObservation { accumulatedPoints += 1 }
        stages.append(accumulatedPoints / 5.0)
        
        // stage 3: 6 points
        accumulatedPoints = 0.0
        if let _ = arrivalTime { accumulatedPoints += 1 }
        if let _ = arrivalLocation { accumulatedPoints += 1 }
        if let _ = arrivalWindSpeed { accumulatedPoints += 1 }
        if let _ = arrivalTide { accumulatedPoints += 1 }
        if let _ = arrivalDepth { accumulatedPoints += 1 }
        if !arrivalTidalCurrent.isEmpty { accumulatedPoints += 1 }
//        if let _ = arrivalObservation { accumulatedPoints += 1 }
        stages.append(accumulatedPoints / 6.0)
        
        // stage 4: 5 points
        accumulatedPoints = 0.0
        if let _ = odometerEnd { accumulatedPoints += 1 }
        if let _ = fuelEnd { accumulatedPoints += 1 }
        if let _ = milesMadeGood { accumulatedPoints += 1 }
        if let _ = averageSpeed { accumulatedPoints += 1 }
        if let _ = maximumSpeed { accumulatedPoints += 1 }
        stages.append(accumulatedPoints / 5.0)
        
        return stages.avg
    }
    var isCompleted: Bool {
        forceCompletion ||
        percentComplete == 1
    }
    var isArrived: Bool {
        forceCompletion ||
        arrivalTime != nil
    }
    /// Differs from ``isArrived`` because based on location being set even when the time is not known.  Helpful when building a trip from a track.
    var hasArrived: Bool {
        forceCompletion ||
        arrivalLocation != nil && route == nil
    }
    var fromLocation: LocationSnippet? {
        departureLocation
    }
    var toLocation: LocationSnippet? {
        arrivalLocation
    }
    var isPredeparted: Bool {
        predeparture.isCompleted
    }
    var isDeparted: Bool {
        hasArrived ||
        departureTime != nil
    }
}
