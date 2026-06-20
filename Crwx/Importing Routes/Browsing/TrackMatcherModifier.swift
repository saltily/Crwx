//
//  TrackMatcherModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/7/25.
//

import SwiftUI
import FoundationUI
import SwiftData

struct TrackMatcherModifier: ViewModifier {
    @Binding var isPresented: Bool
    let tracksOnLeft: Bool
    @Year private var year
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                NavigationStack {
                    NestOne(year: year, tracksOnLeft: tracksOnLeft)
                        .navigationTitle(tracksOnLeft ? "Tracks <-> Trips" : "Trips <-> Tracks")
                        .toolbarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem {
                                DismissButton()
                                    .fontWeight(.bold)
                            }
                        }
                        .safeAreaInset(edge: .bottom) {
                            HStack {
                                Text(year, format: .number.grouping(.never))
                                Spacer()
                                Stepper("Year", value: $year, in: 2015...Date.now.year)
                                    .labelsHidden()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            .background(.thinMaterial)
                        }
                }
            }
    }
}
extension View {
    func trackMatcher(isPresented: Binding<Bool>, tracksOnLeft: Bool) -> some View {
        modifier(TrackMatcherModifier(isPresented: isPresented, tracksOnLeft: tracksOnLeft))
    }
}
fileprivate struct NestOne: View {
    init(year: Int, tracksOnLeft: Bool) {
        self.year = year
        self.tracksOnLeft = tracksOnLeft
        _trips = .init(filter: .tripsBy(year: year), sort: \.date, order: .reverse, animation: .default)
        _tracks = .init(filter: .tracksBy(year: year), sort: \.date, order: .reverse, animation: .default)
    }
    private let year: Int
    private let tracksOnLeft: Bool
    @Query private var trips: [Trip]
    @Query private var tracks: [Track]
    var body: some View {
        if tracksOnLeft {
            LinkingLists(tracks, trips, background: .darkSeaBlue, puckBackground: .groupBoxTint) { track in
                TrackPuck(track: track)
            } rhs: { trip in
                TripPuck(trip: trip)
            }
        } else {
            LinkingLists(trips, tracks, background: .darkSeaBlue, puckBackground: .groupBoxTint) { trip in
                TripPuck(trip: trip)
            } rhs: { track in
                TrackPuck(track: track)
            }
        }
    }
}
