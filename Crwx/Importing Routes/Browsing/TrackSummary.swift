//
//  TrackSummary.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import FoundationUI

struct TrackSummary: View {
    @Bindable var track: Track
    var body: some View {
        Label {
            HStack {
                VStack(alignment: .leading) {
                    PlaceholderText(track.name, placeholder: "Unnamed")
                    (Text(track.distance, format: .number.precision(.fractionLength(0...1))) +
                     Text(" nm, ") +
                     Text(track.points.count, format: .number) + Text(" points"))
                    .font(.caption)
                }
                Spacer()
                if track.trip != nil {
                    Image(systemName: "book.pages.fill")
                        .foregroundStyle(.secondary)
                        .opacity(0.5)
                }
            }
        } icon: {
            Image(systemName: track.sourceImage)
        }
        .badge(track.date?.formatted(.dateTime.month(.defaultDigits).day().year(.twoDigits)))
    }
}
