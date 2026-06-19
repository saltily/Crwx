//
//  TideTableSection.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/9/25.
//

import SwiftUI

struct TideTableSection: View {
    let predictions: [TidePredictionSnippet]
    var body: some View {
        if let first = predictions.first {
            Section {
                ForEach(predictions, id: \.date) { prediction in
                    HStack {
                        Text(prediction.date, format: .dateTime.hour().minute())
                        Spacer()
                        Group {
                            Text(prediction.isHi ? "H" : "L")
                            Text(prediction.height, format: .number.precision(.fractionLength(1)))
                            Text("ft")
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Tide Table")
            } footer: {
                if let name = first.station?.name {
                    Text(name)
                }
            }
            .seaSection()
        }
    }
}
