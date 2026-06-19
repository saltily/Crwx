//
//  EventLine.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/11/24.
//

import SwiftUI

struct EventLine: View {
    @Binding var event: VoyageEvent
    @Environment(\.tripMapper) private var trip
    var body: some View {
        NavigationLink(destination: EventDetails(event: $event).environment(\.tripMapper, trip)) {
            VStack(alignment: .leading, spacing: 4) {
                TripNote(label: event.time.formatted(.dateTime.hour().minute()), note: event.text)
                EventRelativeSentence(location: event.location) { location in
                    Text(location.coordinate, format: .location.minutes().precision(.fractionLength(1)))
                }
                .foregroundStyle(.secondary)
                .font(.caption2)
            }
//            .opacity(0.8)
//            HStack(alignment: .firstTextBaseline, spacing: 10) {
//                Text(event.time, format: .dateTime.hour().minute())
//                    .frame(width: 65, alignment: .trailing)
//                    .fixedSize()
//                    .minimumScaleFactor(0.5)
//                Text(event.text)
//                    .font(.footnote)
//                    .foregroundStyle(.secondary)
//            }
        }
    }
}

#Preview {
    List {
        EventLine(event: .constant(.random))
    }
    .preferredColorScheme(.dark)
}
