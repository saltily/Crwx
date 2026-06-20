//
//  EventForm.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 5/7/25.
//

import SwiftUI
import FoundationUI
import FocusOnAppear
import WxSalt
import FoundationSalt

struct EventForm: View {
    let event: VoyageEvent
    let onSave: (VoyageEvent) -> ()
    @State private var mutable: VoyageEvent = .init()
    @FocusState private var textIsFocused: Bool
    @PositionTracker private var tracker
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    DatePicker("Time", selection: $mutable.time, displayedComponents: [.date, .hourAndMinute])
                    TextField("Description", text: $mutable.text, axis: .vertical)
                        .focusOnAppear($textIsFocused)
                        .lineLimit(4...)
                }
            }
            .seaSection()
            Section("Location") {
                EventLocationPicker(label: mutable.time.formatted(.dateTime.hour().minute()), coordinate: $mutable.location)
            }
            .seaSection()
        }
        .seaBackground(.darkSeaBlue)
        .onChange(of: event, initial: true) { oldValue, newValue in
            if mutable.id != newValue.id {
                mutable = newValue
                if newValue.location == nil,
                   newValue.time.timeIntervalSinceNow.magnitude < 1.minute
                {
                    Task {
                        if let currentLocation = await tracker.currentLocation {
                            mutable.location = .make(from: currentLocation)
                        }
                    }
                }
            }
        }
        .onAppear {
            textIsFocused = true
        }
        .cancelButton()
        .saveButton {
            onSave(mutable)
        }
    }
}

struct EditEventModifier: ViewModifier {
    @Binding var event: VoyageEvent?
    let label: String
    let onSave: (VoyageEvent) -> ()
    @Environment(\.tripMapper) private var trip
    func body(content: Content) -> some View {
        content
            .sheet(item: $event) { event in
                NavigationStack {
                    EventForm(event: event, onSave: onSave)
                        .navigationTitle(label)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .environment(\.tripMapper, trip)
            }
    }
}
extension View {
    func editEvent(_ event: Binding<VoyageEvent?>, label: String, onSave: @escaping (VoyageEvent) -> ()) -> some View {
        modifier(EditEventModifier(event: event, label: label, onSave: onSave))
    }
}
