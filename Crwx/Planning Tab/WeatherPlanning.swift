//
//  WeatherPlanning.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/22/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct WeatherPlanning: View {
    var body: some View {
        Section("Weather") {
            WeatherPathLink(.marineWeather)
            WeatherPathLink(.tides)
            WeatherPathLink(.currents)
            WeatherPathLink(.seaBuoy)
            WeatherPathLink(.radar)
        }
        .seaSection()
    }
}

#Preview {
    NavigationStack {
        List {
            WeatherPlanning()
        }
        .navigationTitle("Weather")
            .seaBackground()
            .navigationDestination(for: WeatherPath.self) { path in
                WeatherPathDestinationView(path: path)
                    .seaBackground()
            }
    }
    .environment(\.wxColourScheme, .green)
    .locationManager()
}
