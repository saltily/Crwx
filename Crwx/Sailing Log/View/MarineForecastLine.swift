//
//  MarineForecastLine.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/7/24.
//

import SwiftUI
import WxSalt

struct MarineForecastLine: View {
    let forecast: ForecastSnippet?
    var body: some View {
        if let forecast {
            HStack {
                Text("Marine")
                    .foregroundStyle(.primary)
                Spacer()
                if let _ = forecast.lowWaveFeet {
                    // waves
                    Text(forecast.wavesSummary)
                    // wind
                    WindDirectionSymbol(directions: .init(directions: forecast.winds.angles))
                        .padding(.leading, 10)
                    Text(forecast.winds.summaryWithGusts)
                }
                else {
                    Text(forecast.text)
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    List {
        MarineForecastLine(forecast: .random(true, point: nil))
            .foregroundColor(.secondary)
    }
    .preferredColorScheme(.dark)
}
