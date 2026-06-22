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
            Text("Tides")
            Text("Tidal Currents")
            Text("Sea Buoy")
        }
        .seaSection()
    }
}

#Preview {
    WeatherPlanning()
}
