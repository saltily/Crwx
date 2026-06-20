//
//  TripPuck.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/7/25.
//

import SwiftUI
import FoundationUI
import MapKit

struct TripPuck: View {
    @Bindable var trip: Trip
    var body: some View {
        VStack {
            HStack {
                Text(trip.date, format: .dateTime.month(.defaultDigits).day().year(.twoDigits))
                Spacer()
                if let mmg = trip.milesMadeGood {
                    let s = mmg.formatted(.number.precision(.fractionLength(1)))
                    Text("\(s) nm")
                        .foregroundStyle(.secondary)
                }
            }
            ZStack {
                SaltMap {
                    MapDot(trip.departureLocation, tint: .accentColor)
                    MapDot(trip.arrivalLocation, tint: .accentColor)
                }
                .northUp()
                .panningDisabled()
                TrackHintsOverlay(cmg: trip.cmg)
            }
            .aspectRatio(1.0, contentMode: .fill)
        }
        .padding()
    }
}
