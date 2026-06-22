//
//  MultipleTripsModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/7/25.
//

import SwiftUI
import FoundationUI
import SwiftData
import FoundationSalt

struct MultipleTripsModifier: ViewModifier {
    let countSentence: String
    let selection: Set<UUID>
    func body(content: Content) -> some View {
        content
            .navigationSubtitle(countSentence)
            .safeAreaInset(edge: .bottom) {
                FooterView(countSentence: countSentence, selection: selection)
            }
    }
    
}
extension View {
    func multipleTrips(selection: Set<UUID>, countSentence: String) -> some View {
        modifier(MultipleTripsModifier(countSentence: countSentence, selection: selection))
    }
}
fileprivate struct FooterView: View {
    let countSentence: String
    let selection: Set<UUID>
    @Environment(\.modelContext) private var context
    @Environment(\.editMode) private var editMode
    var body: some View {
        if selection.isEmpty || editMode?.wrappedValue != .active {
            EmptyView()
//            Text(countSentence)
        } else {
            let trips = selection.compactMap {
                Trip.find($0, in: context)
            }.sorted(by: \.date)
            VStack(alignment: .center, spacing: 5) {
                // start with hours underway, number of days and anchorages
                Text(trips.hoursDaysAndAnchorages)
                // then actual miles sailed and sog avg
                Text(trips.actualMilesAndSpeedOverGroundSentence)
                // then mmg and smg
                Text(trips.milesMadeGoodAndSpeedMadeGoodSentence)
                // then max speed and fuel consumption
                Text(trips.maxSpeedAndFuelConsumptionSentence)
                MakeCruiseButton(selection: selection)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.caption)
            .padding()
            .background(.thinMaterial)
        }
    }
}
extension [Trip] {
    var hoursDaysAndAnchorages: String {
        let hours = self.totalHours
        let days = self.countUniqueDays
        let avg = hours / days.double
        let harbours = self.countUniqueHarbours
        return "Sailed \(hours.rounded) hrs over \(days.appending("day", "days")) or \(avg.formatted(.number.precision(.fractionLength(0...1)))) hrs / day, visiting \(harbours.appending("place", "places"))."
    }
    var actualMilesAndSpeedOverGroundSentence: String {
        let miles = self.totalMiles
        let days = self.countUniqueDays
        let diem = miles / days.double
        let hours = self.totalSpeedDuration / .Hour
        let avg = miles / hours
        return "Sailed \(miles.rounded) nm or \(diem.formatted(.number.precision(.fractionLength(0...1)))) nm / day.  \(avg.formatted(.number.precision(.fractionLength(0...1)))) kts avg."
    }
    var milesMadeGoodAndSpeedMadeGoodSentence: String {
        let miles = self.milesMadeGood
        let days = self.countUniqueDays
        let diem = miles / days.double
        let hours = self.totalSpeedDuration / .Hour
        let avg = miles / hours
        return "Made good \(miles.rounded) nm or \(diem.formatted(.number.precision(.fractionLength(0...1)))) nm / day.  \(avg.formatted(.number.precision(.fractionLength(0...1)))) kts avg."
    }
    var maxSpeedAndFuelConsumptionSentence: String {
        let m: String
        if let max = self.maxSpeed {
            m = "Max speed \(max.formatted(.number.precision(.fractionLength(0...1)))) kts.  "
        } else { m = "" }
        let gallons = self.gallonsConsumed
        let miles = self.totalMiles
        let mpg = miles / gallons
        return "\(m)Burned \(gallons.formatted(.number.precision(.fractionLength(0...1)))) gals of fuel or \(mpg.formatted(.number.precision(.fractionLength(0...1)))) mpg."
    }
}

extension [Trip] {
    var totalHours: Double {
        self.compactMap { $0.duration }.sum / .Hour
    }
    var countUniqueDays: Int {
        self.map { $0.date.day }.set.count
    }
    var countUniqueHarbours: Int {
        self.compactMap { $0.harbours }.flatMap { $0 }.map { $0.id }.set.count
    }
    var totalMiles: Double {
        self.compactMap { $0.milesMadeGood }.sum
    }
    var totalSpeedDuration: TimeInterval {
        self.compactMap { $0.durationBySpeed }.sum
    }
    var milesMadeGood: Double {
        self.compactMap { $0.route?.distance ?? $0.overallLeg?.nauticalMiles }.sum
    }
    var maxSpeed: Double? {
        self.compactMap { $0.maximumSpeed }.max()
    }
    var gallonsConsumed: Double {
        self.compactMap { $0.gallonsConsumed }.sum
    }
}
extension Trip {
    fileprivate var durationBySpeed: TimeInterval? {
        if let averageSpeed,
           let milesMadeGood
        {
            return milesMadeGood / averageSpeed * .Hour
        }
        return duration
    }
}
