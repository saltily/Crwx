//
//  BuoyLine.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/7/24.
//

import SwiftUI
import WxSalt
import FoundationSalt

struct BuoyLine: View {
    let observation: ObservationSnippet?
    var body: some View {
        if let observation {
            HStack {
                Text("Buoy")
                    .foregroundStyle(.primary)
                Spacer()
                if let waveHeight = observation.waveHeight {
                    let s = waveHeight.formatted(.number.precision(.fractionLength(0...1)))
                    Text("\(s) ft")
                }
                if let period = observation.period {
                    Text("\(period.rounded) sec")
                }
                WindDirectionSymbol(directions: .init(observation.windAngle))
                    .padding(.leading, 10)
                if let _ = observation.windDirection {
                    Text(observation.compassDirection.abbreviation)
                }
                if let windSpeed = observation.windSpeed {
                    Text(windSpeed.rounded, format: .number)
                    if let gust = observation.gust,
                       gust.rounded != windSpeed.rounded
                    {
                        Text("G\(gust.rounded)")
                    }
                }
            }
        }
    }
}

#Preview("Random") {
    List {
        BuoyLine(observation: .random())
            .foregroundColor(.secondary)
    }
}
