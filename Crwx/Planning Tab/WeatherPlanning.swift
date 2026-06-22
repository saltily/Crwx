//
//  WeatherPlanning.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/22/26.
//

import SwiftUI
import WxSalt

struct WeatherPlanning: View {
    var body: some View {
        Section("Weather") {
            MarineWeatherRow()
            Label("Tides", systemImage: WeatherAngle.tide.symbolName)
            Label("Tidal Currents", systemImage: WeatherSource.tidalCurrents.symbolName)
            Label("Sea Buoy", systemImage: WeatherSource.marineBuoy.symbolName)
        }
        .seaSection()
    }
}

#Preview {
    WeatherPlanning()
}
