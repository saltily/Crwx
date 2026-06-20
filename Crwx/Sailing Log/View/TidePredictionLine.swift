//
//  TidePredictionLine.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/7/24.
//

import SwiftUI
import FoundationSalt

struct TidePredictionLine: View {
    let predictions: [TidePredictionSnippet]
    var body: some View {
        if let daytimeHi {
            HStack(spacing: 10) {
                Text("Tide")
                    .foregroundStyle(.primary)
                Spacer()
                Text("H")
                Text(daytimeHi.date, format: .dateTime.hour().minute())
                let s = daytimeHi.height.formatted(.number.precision(.fractionLength(1)))
                Text("\(s) ft")
            }
        }
    }
    private var daytimeHi: TidePredictionSnippet? {
        predictions.first {
            $0.isHi &&
            $0.date.timeAsInterval > 6.hour
        }
    }}

#Preview {
    List {
        TidePredictionLine(predictions: .random(on: .now))
            .foregroundColor(.secondary)
    }
}
