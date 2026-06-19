//
//  AddEventButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 5/7/25.
//

import SwiftUI

struct AddEventButton: View {
    @Binding var events: [VoyageEvent]
    var padded = false
    @State private var newEvent: VoyageEvent?
    var body: some View {
        Button {
            newEvent = .init()
        } label: {
            Label("Log Event", systemImage: "camera")
                .padding(.vertical, padded ? nil : 0)
        }
        .editEvent($newEvent, label: "Log Event") { event in
            events.append(event) // it will sort and save
        }
    }
}
