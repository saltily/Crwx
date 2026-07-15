//
//  WeatherPathDestinationView.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import CoreLocation
import FoundationUI
import WxSalt

struct WeatherPathDestinationView: View {
    let path: WeatherPath
    @State private var currentLocation: CLLocation?
    var body: some View {
        switch path {
        case .marineWeather:
            MarineWeatherBrowser(location: currentLocation)
                .fetchLocation(into: $currentLocation)
        default:
            Text("Under Development")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    NavigationStack {
        WeatherPathDestinationView(path: .marineWeather)
            .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
    .locationManager()
}
