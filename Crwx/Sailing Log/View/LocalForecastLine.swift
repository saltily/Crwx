//
//  LocalForecastLine.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/7/24.
//

import SwiftUI
import WxSalt
import FoundationSalt

struct LocalForecastLine: View {
    let forecast: ForecastSnippet?
    var body: some View {
        if let forecast,
           forecast.hasSomething
        {
            HStack {
                Text("Local")
                    .foregroundStyle(.primary)
                Spacer()
                if !forecast.symbolName.isEmpty {
                    Image(systemName: forecast.symbolName)
                        .renderingMode(.original)
                        .symbolVariant(.fill)
                        .frame(height: 10)
                }
                if let highTemperature = forecast.highTemperature {
                    Text("\(highTemperature.rounded)º")
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

#Preview("Random") {
    List {
        LocalForecastLine(forecast: .random(point: .random))
            .foregroundColor(.secondary)
    }
    .preferredColorScheme(.dark)
}
