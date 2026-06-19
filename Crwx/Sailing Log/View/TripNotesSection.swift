//
//  TripNotesSection.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/8/25.
//

import SwiftUI

struct TripNotesSection: View {
    @Bindable var trip: Trip
    var body: some View {
        if trip.hasNotes {
            Section {
                TripNote(label: "Summary", note: trip.comments)
                ForEach(trip.events) { event in
                    TripNote(label: event.time.formatted(.dateTime.hour().minute()), note: event.text)
                }
            }
            .seaSection()
        }
    }
}

struct TripNote: View {
    let label: String
    let note: String
    var body: some View {
        if !note.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text(note)
                    .font(.callout)
            }
        }
    }
}
