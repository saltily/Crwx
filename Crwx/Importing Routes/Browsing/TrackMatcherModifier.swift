//
//  TrackMatcherModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/7/25.
//

import SwiftUI
import FoundationUI
import SwiftData
import FoundationSalt
import WxSalt

struct TrackMatcherModifier: ViewModifier {
    init(isPresented: Binding<Bool>, tracksOnLeft: Bool, year: Int) {
        self._isPresented = isPresented
        self.tracksOnLeft = tracksOnLeft
        self.year = year
        self._mutableYear = .init(initialValue: year)
    }
    @Binding var isPresented: Bool
    let tracksOnLeft: Bool
    let year: Int
    @State private var mutableYear: Int
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                NavigationStack {
                    NestOne(year: mutableYear, tracksOnLeft: tracksOnLeft)
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
                                Text(mutableYear, format: .number.grouping(.never))
                                Spacer()
                                Stepper("Year", value: $mutableYear, in: 2015...Date.now.year)
                                    .labelsHidden()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            .background(.thinMaterial)
                        }
                        .onChange(of: year, initial: true) { oldValue, newValue in
                            mutableYear = newValue
                        }
                }
            }
    }
}
extension View {
    func trackMatcher(isPresented: Binding<Bool>, tracksOnLeft: Bool, year: Int) -> some View {
        modifier(TrackMatcherModifier(isPresented: isPresented, tracksOnLeft: tracksOnLeft, year: year))
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
            LinkingLists(tracks, trips, background: .darkSeaGreen, puckBackground: .groupBoxTint) { track in
                TrackPuck(track: track)
            } rhs: { trip in
                TripPuck(trip: trip)
            }
        } else {
            LinkingLists(trips, tracks, background: .darkSeaGreen, puckBackground: .groupBoxTint) { trip in
                TripPuck(trip: trip)
            } rhs: { track in
                TrackPuck(track: track)
            }
        }
    }
}
