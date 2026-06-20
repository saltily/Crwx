//
//  SegmentRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/10/25.
//

import SwiftUI

struct SegmentRow: View {
    let points: [TrackPoint]
    let colour: Color
    var body: some View {
        HStack(spacing: 15) {
            Rectangle()
                .fill(colour)
                .frame(width: 10)
            let startTime = points.first?.time
            let endTime = points.last?.time
            let (distance, duration, speed, gain) = points.measure()
            VStack(alignment: .leading) {
                HStack {
                    Text(distance, format: .number.precision(.fractionLength(0...1))) + Text(" nm")
                    Spacer()
                    if let duration {
                        Text(duration, format: .duration.driving)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack(spacing: 15) {
                    if let startTime,
                       let endTime
                    {
                        Text(startTime, format: .dateTime.month(.defaultDigits).day().year(.twoDigits)) + Text(", ") +
                        Text(startTime, format: .dateTime.hour().minute()) + Text("-") +
                        Text(endTime, format: .dateTime.hour().minute())
                    }
                    Spacer()
                    if let speed {
                        Text(speed, format: .number.precision(.fractionLength(1))) + Text(" kts")
                    }
                    if let gain {
                        Text(gain, format: .number.precision(.fractionLength(0))) + Text(" ft")
                    }
                }
                .font(.caption)
            }
        }
        .padding(.trailing)
        .frame(height: 50)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
