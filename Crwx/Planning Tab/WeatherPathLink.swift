//
//  WeatherPathLink.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import FoundationUI

struct WeatherPathLink: View {
    init(_ value: WeatherPath) {
        self.value = value
    }
    let value: WeatherPath
    var body: some View {
        NavigationLink(value.label, systemImage: value.systemImage, value: value)
    }
}

#Preview {
    WeatherPathLink(.marineWeather)
}
