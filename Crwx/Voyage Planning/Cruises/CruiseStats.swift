//
//  CruiseStats.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/7/25.
//

import SwiftUI
import FoundationSalt

struct CruiseStats: View {
    @Bindable var cruise: CruiseViewModel
    var body: some View {
        let trips = cruise.legs.compactMap { $0.trip }.filter {
            $0.isCompleted
        }
        VStack(alignment: .leading, spacing: 5) {
            // start with hours underway, number of days and anchorages
            if !cruise.isComplete {
                Text(cruise.plannedDaysAndAnchorages)
            }
            if !trips.isEmpty {
                Text(trips.hoursDaysAndAnchorages)
                // then actual miles sailed and sog avg
                Text(trips.actualMilesAndSpeedOverGroundSentence)
            }
            // then mmg and smg
            Text(cruise.milesMadeGoodAndSpeedMadeGoodSentence(trips))
            // then max speed and fuel consumption
            if !trips.isEmpty {
                Text(trips.maxSpeedAndFuelConsumptionSentence)
            }
        }
        .font(.caption)
    }
}

extension CruiseViewModel {
    var isComplete: Bool {
        for leg in legs {
            if leg.trip == nil { return false }
        }
        return true
    }
    var plannedDaysAndAnchorages: String {
        let days = self.anchorages.count - 1
        let anchorages = self.countUniqueHarbours
        return "Planned for \(days.appending("day", "days")), visiting \(anchorages.appending("anchorage", "anchorages"))."
    }
    func milesMadeGoodAndSpeedMadeGoodSentence(_ trips: [Trip]) -> String {
        let miles = self.mmg
        let days = self.anchorages.count - 1
        let diem = miles / days.double
        let kts_avg: String
        if !trips.isEmpty {
            let hours = trips.totalSpeedDuration / .Hour
            let avg = trips.milesMadeGood / hours
            kts_avg = "\(avg.formatted(.number.precision(.fractionLength(0...1)))) kts avg."
        } else { kts_avg = "" }
        let made = isComplete ? "Made" : "Make"
        return "\(made) good \(miles.rounded) nm or \(diem.formatted(.number.precision(.fractionLength(0...1)))) nm / day.\(kts_avg)"
    }
}

extension CruiseViewModel {
//    var totalHours: Double {
//        self.compactMap { $0.duration }.sum / .Hour
//    }
//    var countUniqueDays: Int {
//        self.map { $0.date.day }.set.count
//    }
    var countUniqueHarbours: Int {
        anchorages.map { $0.harbour.id }.set.count
    }
//    var totalMiles: Double {
//        self.compactMap { $0.milesMadeGood }.sum
//    }
//    var totalSpeedDuration: TimeInterval {
//        self.compactMap { $0.durationBySpeed }.sum
//    }
//    var milesMadeGood: Double {
//        self.compactMap { $0.route?.distance ?? $0.overallLeg?.nauticalMiles }.sum
//    }
//    var maxSpeed: Double? {
//        self.compactMap { $0.maximumSpeed }.max()
//    }
//    var gallonsConsumed: Double {
//        self.compactMap { $0.gallonsConsumed }.sum
//    }
}
