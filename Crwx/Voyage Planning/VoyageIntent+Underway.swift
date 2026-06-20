//
//  VoyageIntent+Underway.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/5/25.
//

import Foundation
import FoundationSalt
import SwiftData

extension PotentialAnchorages.Engine {
    func loadConditions(underway: ClosedRange<Date>, start: UUID) async throws -> ([WindSnippet], [Range<Date>]) {
        try Task.checkCancellation()
        guard let harbour = Harbour.find(start, in: modelContext)
        else { throw E.BadId }
        
        // winds
        try Task.checkCancellation()
        let forecast = try await forecasts.forecast(for: harbour.marineZone, during: underway)
        let winds = forecast.flatMap { $0.winds }
        
        // floods
        try Task.checkCancellation()
        let predictions = try await forecasts.predictions(for: harbour.tideStation, during: underway)
        try Task.checkCancellation()
        let floodingMinutes = predictions.minutesFlooding(during: underway.lowerBound..<underway.upperBound)
        let minutesRanges = floodingMinutes.map {
            $0 / 60
        }.ranges
        let floodRanges: [Range<Date>] = minutesRanges.map {
            let lowerBound = Date(timeIntervalSinceReferenceDate: $0.lowerBound.double * .Minute)
            let upperBound = Date(timeIntervalSinceReferenceDate: $0.upperBound.double * .Minute)
            return lowerBound..<upperBound
        }
        
        try Task.checkCancellation()
        return (winds, floodRanges)
    }
}
