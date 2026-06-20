//
//  TrackPuck.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/7/25.
//

import SwiftUI
import FoundationUI
import MapKit

struct TrackPuck: View {
    @Bindable var track: Track
    var body: some View {
        VStack {
            HStack {
                PlaceholderText(track.date?.formatted(.dateTime.month(.defaultDigits).day().year(.twoDigits)) ?? "", placeholder: "Unknown Date")
                Spacer()
                let s = track.totalLength.formatted(.number.precision(.fractionLength(1)))
                Text("\(s) nm")
                    .foregroundStyle(.secondary)
            }
            ZStack {
                SaltMap {
                    MapDot(track.start)
                    MapDot(track.end)
                    Polyline(track.points)
                }
                .northUp()
                .panningDisabled()
                TrackHintsOverlay(cmg: track.cmg)
            }
            .aspectRatio(1.0, contentMode: .fill)
        }
        .padding()
    }
}
