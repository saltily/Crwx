//
//  AllTripsView.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import SwiftData
import FoundationUI
import WxSalt
import FoundationSalt

struct AllTripsView: View {
    @Year private var year
    var body: some View {
        TripsFetcher(year: year)
    }
}

#Preview {
    NavigationStack {
        AllTripsView()
            .seaBackground()
    }
    .modelContainer(previewContainer)
    .preferredColorScheme(.dark)
    .locationManager()
    .environment(WxEngine())
}

fileprivate struct TripsFetcher: View {
    init(year: Int) {
        _trips = .init(filter: .tripsBy(year: year), sort: .defaultSortOrder(year), animation: .default)
        self.year = year
    }
    @Query private var trips: [Trip]
    private let year: Int
    var body: some View {
        TripsLoop(trips: trips, year: year)
    }
}
fileprivate struct TripsLoop: View {
    let trips: [Trip]
    let year: Int
    @State private var selectedTrips: Set<UUID> = []
    @State private var shareState = ShareState()
    @Environment(\.modelContext) private var context
    var body: some View {
        ScrollViewReader { proxy in
            List(selection: $selectedTrips) {
                Group {
                    Section {
                        ChooseAnchorageRow()
                        NavigationLink(destination: GridHelper()) {
                            Text("Grid Helper")
                        }
                    }
                    if addSection {
                        Section {
                            NewTripButton()
                                .legacyTripSheet(proxy)
                        } header: {
                            Text(Date.now, format: .dateTime.month(.wide).year())
                        }
                    }
                    ForEach(trips.grouped(by: \.date.monthYear, sorting: {
                        if year == Date.now.year {
                            $0 > $1
                        } else {
                            $0 < $1
                        }
                    })) { section in
                        Section {
                            if section.id == Date.now.monthYear,
                               showAddTripButton
                            {
                                NewTripButton()
                                    .legacyTripSheet(proxy)
                            }
                            ForEach(section.contents) { trip in
                                NavigationLink(destination: TripView(trip: trip))
                                {
                                    TripSummaryRow(trip: trip)
                                        .legacyTripSheet(proxy, date: trip.date)
                                        .swipeToShare {
                                            shareState.start()
                                            do {
                                                let url = try await trip.share(context)
                                                url.absoluteString.copyToPasteboard()
                                                shareState.complete()
                                            } catch {
                                                shareState.error(error)
                                            }
                                        }
                                }
                                .banded(trip.cruise?.sampleColour)
                                .id(trip.persistentModelID)
                            }
                        } header: {
                            HStack {
                                Text(section.id.first, format: .dateTime.month(.wide).year())
                                Spacer()
                                Text(section.map { $0.date.dayYear }.set.count.appending("day", "days"))
                            }
                        }
                    }
                }
                .seaSection()
            }
            .listStyle(.grouped)
            .navigationTitle("Voyage Log")
            .isSharing(shareState)
            .multipleTrips(selection: selectedTrips, countSentence: countSentence)
        }
        
    }
    /// Number of trips and days being displayed.
    private var countSentence: String {
        let trips = trips.count.appending("Trip", "Trips")
        let days = countDays.appending("Day", "Days")
        return "\(trips), \(days)"
    }
    
    /// The number of different days the trips happened on.
    private var countDays: Int {
        trips.map { $0.date.dayYear }.set.count
    }
    
    /// If this month does not appear in the trip sections
    private var addSection: Bool {
        let thisMonth = Date.now.monthYear
        guard year == thisMonth.year else { return false } // only for current year
        if trips.contains(where: {
            $0.date.monthYear == thisMonth
        }) {
            return false
        }
        return true
    }
    
    /// If there is not an incomplete trip open for today - or arrived should be good enough
    private var showAddTripButton: Bool {
        let today = Date.now.withoutTime
        guard year == today.year else { return false } // only for current year
        if trips.contains(where: {
            !$0.isArrived &&
            $0.date.withoutTime == today
        }) {
            return false
        }
        return true
    }
}
extension Cruise {
    var sampleColour: Color {
        let pattern = ColorPattern(colours)
        return pattern[0]
    }
}
