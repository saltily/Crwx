//
//  TripView.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/15/25.
//

import SwiftUI
import FoundationSalt
import WxSalt

struct TripView: View {
    @Bindable var trip: Trip
    var body: some View {
        Group {
            if trip.isCompleted,
               trip.arrivalTime?.isToday == false
            {
                TripOverview(trip: trip)
            } else {
                TripEditor(trip: trip)
                    .returnToWx()
            }
        }
        .seaBackground()
    }
}
