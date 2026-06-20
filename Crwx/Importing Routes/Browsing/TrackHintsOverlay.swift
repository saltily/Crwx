//
//  TrackHintsOverlay.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/10/25.
//

import SwiftUI

struct TrackHintsOverlay: View {
    var track: Track?
    var cmg: Measurement<UnitAngle>?
    var body: some View {
        HStack(spacing: 10) {
            Group {
                if let cmg {
                    Image(systemName: "location.north.line.fill")
                        .rotationEffect(.degrees(cmg.converted(to: .degrees).value))
                } else {
                    Image(systemName: "arrow.trianglehead.clockwise")
                }
            }
            .opacity(0.7)
            if let track {
                TrackTripButton(track: track)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

#Preview {
    TrackHintsOverlay()
}
