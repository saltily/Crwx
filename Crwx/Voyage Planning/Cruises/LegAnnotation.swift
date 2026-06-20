//
//  LegAnnotation.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import MapKit

struct LegAnnotation: MapContent {
    let leg: CruiseViewModel.Leg
    var body: some MapContent {
        Annotation("", coordinate: leg.middle, anchor: .center) {
            VStack(spacing: 2) {
                HStack {
                    if let bearing = leg.bearing {
                        Image(systemName: "location.north.line.fill")
                            .rotationEffect(.degrees(bearing.converted(to: .degrees).value))
                    }
                    Text(leg.totalMiles, format: .number.precision(.fractionLength(0...1))) + Text(" nm")
                }
                Text(leg.winds.summary)
            }
            .font(.caption)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.8), radius: 3)
        }
    }
}
