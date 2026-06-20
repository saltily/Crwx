//
//  AnchorageTidePredictions.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/13/25.
//

import SwiftUI
import WxSalt

struct AnchorageTidePredictions: View {
    init(predictions: [TidePrediction], days: ClosedRange<Date>) {
        self.predictions = predictions.filter {
            days.contains($0.date)
        }
    }
    let predictions: [TidePrediction]
    var body: some View {
        ForEach(predictions.grouped(by: \.date.day)) { dayGroup in
            VStack(alignment: .leading, spacing: 8) {
                Text(dayGroup.id.start, format: .dateTime.weekday(.wide))
                    .font(.headline)
                ForEach(dayGroup) { prediction in
                    TidePredictionRow(prediction: prediction)
                }
            }
        }
    }
}
