//
//  SegmentRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/10/25.
//

import SwiftUI
import FoundationSalt

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
                    let s = distance.formatted(.number.precision(.fractionLength(0...1)))
                    Text("\(s) nm")
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
                        let s1 = startTime.formatted(.dateTime.month(.defaultDigits).day().year(.twoDigits))
                        let s2 = startTime.formatted(.dateTime.hour().minute())
                        let s3 = endTime.formatted(.dateTime.hour().minute())
                        Text("\(s1), \(s2)-\(s3)")
                    }
                    Spacer()
                    if let speed {
                        let s = speed.formatted(.number.precision(.fractionLength(1)))
                        Text("\(s) kts")
                    }
                    if let gain {
                        let s = gain.formatted(.number.precision(.fractionLength(0)))
                        Text("\(s) ft")
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
