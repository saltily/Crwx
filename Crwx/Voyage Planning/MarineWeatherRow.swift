//
//  MarineWeatherRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/16/25.
//

import SwiftUI
import FoundationUI
import CoreLocation
import WxSalt

struct MarineWeatherRow: View {
    @State private var currentLocation: CLLocation?
    var body: some View {
        NavigationLink(destination: MarineWeatherBrowser(location: currentLocation).seaBackground()) {
            Label("Marine Forecast", systemImage: "text.page")
        }
        .fetchLocation(into: $currentLocation)
    }
}

#Preview {
    MarineWeatherRow()
}
