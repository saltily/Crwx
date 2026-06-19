//
//  MarineForecastSection.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/9/25.
//

import SwiftUI
import WxSalt

struct MarineForecastSection: View {
    let forecast: ForecastSnippet?
    let observation: ObservationSnippet?
    var body: some View {
        if forecast != nil || observation != nil {
            Section {
                if let forecast {
                    HStack {
                        WindDirectionSymbol(directions: .init(directions: forecast.winds.angles))
                        Text(forecast.winds.summaryWithGusts)
                    }
                    .labeled("Wind")
                    Text(forecast.wavesSummary)
                        .labeled("Waves")
                    if !forecast.text.isEmpty {
                        Text(forecast.text)
                            .font(.callout)
                    }
                }
                BuoyLine(observation: observation)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Marine Forecast")
            } footer: {
                if let name = forecast?.zone?.name {
                    Text(name)
                }
            }
            .seaSection()
        }
    }
}
