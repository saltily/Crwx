//
//  CruiseRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/7/25.
//

import SwiftUI
import FoundationUI

struct CruiseRow: View {
    @Bindable var cruise: Cruise
    @Environment(\.modelContext) private var context
    var body: some View {
        let pattern = ColorPattern(cruise.colours)
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 3) {
                Text(cruise.start.start, format: .dateTime.month(.defaultDigits).day().weekday())
                Text("-")
                Text(cruise.start.start.adding(days: cruise.anchorages.count - 2), format: .dateTime.month(.defaultDigits).day().weekday())
                Spacer()
                if cruise.webId != nil {
                    Image(systemName: "square.and.arrow.up")
                        .opacity(0.3)
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
                if cruise.isLocked {
                    Image(systemName: "lock.fill")
                        .opacity(0.3)
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
            }
            .font(.headline)
            Divider()
                .padding(.vertical, 3)
            Group {
                Text(sentence1)
                Text(sentence2)
            }
            .font(.caption)
        }
        .padding(.vertical, 8)
        .editCruise(cruise)
        .banded(pattern[0])
        .deleteCruise(cruise)
    }
    /// "Machiasport to Ellsworth, 8 stops in 8 days"
    private var sentence1: String {
        let anchorages = cruise.anchorages
        guard !anchorages.isEmpty else { return "0 stops" }
        let unique = anchorages.map { $0.harbourId }.set
        let stops = (unique.count - 1).appending("stop", "stops")
        let days = (anchorages.count - 1).appending("day", "days")
        guard let first = Harbour.find(anchorages.first?.harbourId, in: context),
              let last = Harbour.find(anchorages.last?.harbourId, in: context)
        else { return "\(stops) in \(days)" }
        return "\(first.name) to \(last.name), \(stops) in \(days)"
    }
    /// "150 miles, 18.7 per day"
    private var sentence2: String {
        guard let vm = try? cruise.viewModel(in: context)
        else { return "" }
        let miles = vm.totalMiles
        let days = vm.legs.count.nilIfZero ?? 1
        let milesPerDay = miles / days.double
        return "\(miles.rounded.formatted(.number)) miles, \(milesPerDay.formatted(.number.precision(.fractionLength(0...1)))) per day"
    }
}
