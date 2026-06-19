//
//  CurrentTideView.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/8/25.
//

import SwiftUI
import CoreLocation
import FoundationSalt
import WxSalt

struct CurrentTideView: View {
    let time: Date
    let location: any Mappable
    @State private var forecasts = CoastalForecasts()
    @State private var tide: TideSnapshot?
    @StateObject private var task = PerformTask<TideSnapshot?>(multiple: .replacesRunning)
    var body: some View {
        HStack {
            if let tide {
                Text(tide.height.converted(to: .feet).value, format: .number.precision(.fractionLength(1))) + Text(" ft")
                Image(systemName: tide.movement.symbolName)
            }
            else {
                Group {
                    Text("10.3 ft")
                    Image(systemName: "arrow.up")
                }
                .redacted(reason: .placeholder)
            }
        }
        .onChange(of: time, initial: true) { oldValue, newValue in
            refreshTide()
        }
        .onChange(of: location.coordinate) { oldValue, newValue in
            refreshTide()
        }
    }
    private func refreshTide() {
        task.perform {
            guard let station = TideStation.nearest(to: location)
            else { return nil }
            return try await forecasts.tide(for: station, at: time)
        } then: { tide in
            self.tide = tide
        }
    }
}
