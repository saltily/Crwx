//
//  LocalForecastSection.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/9/25.
//

import SwiftUI
import WxSalt
import FoundationUI

struct LocalForecastSection: View {
    let forecast: ForecastSnippet?
    var body: some View {
        if let forecast {
            Section {
                HStack {
                    if let highTemperature = forecast.highTemperature {
                        let s = highTemperature.formatted(.number.precision(.fractionLength(0)))
                        Text("\(s)º")
                    }
                    ForecastConditionsSymbol(forecast: forecast)
                }
                .labeled("Conditions")
                HStack {
                    WindDirectionSymbol(directions: .init(directions: forecast.winds.angles))
                    Text(forecast.winds.summaryWithGusts)
                }
                .labeled("Wind")
                if !forecast.text.isEmpty {
                    Text(forecast.text)
                        .font(.callout)
                }
            } header: {
                Text("Local Forecast")
            } footer: {
                if let name = forecast.point?.name {
                    Text(name)
                }
            }
            .seaSection()
        }
    }
}
