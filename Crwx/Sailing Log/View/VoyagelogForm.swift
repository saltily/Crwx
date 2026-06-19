//
//  VoyagelogForm.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import CoreLocation

struct VoyagelogForm: View {
    @State var model: VoyageLogViewModel
    @State private var newEvent: VoyageEvent?
    @PositionTracker private var tracker
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Group {
                    if let _ = newEvent {
                        Section {
                            VoyageeventEditorRow(event: $newEvent)
                        } header: {
                            Text("New Event")
                        } footer: {
                            if let location = newEvent?.location {
                                Text(location.coordinate, format: .location.minutes().precision(.fractionLength(2)))
                            }
                        }
                    }
                    Section("Events") {
                        ForEach($model.events) { $event in
                            EventLine(event: $event)
                            .swipeActions {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    model.events = model.events.filter {
                                        $0.id != event.id
                                    }
                                }
                            }
                        }
                    }
                }
                .seaSection()
            }
            .listStyle(.grouped)
            .seaBackground(.darkSeaBlue)
            .navigationTitle("Voyage Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button(systemImage: "plus") {
                        if let newEvent {
                            model.events.append(newEvent)
                            model.sort()
                        }
                        generateEvent()
                    }
                    Button("Save") {
                        dismiss()
                        if let newEvent,
                           !newEvent.text.isEmpty
                        {
                            model.events.append(newEvent)
                            model.sort()
                        }
                        model.trip?.update(voyagelog: model)
                    }
                }
            }
            .onAppear {
                if model.tripIsActive {
                    generateEvent()
                }
            }
        }
    }
    
    private func generateEvent() {
        Task {
            let loc = await tracker.currentLocation // ?? .randomOnCoastOfMaine()
            newEvent = .init(location: loc?.coordinate.codable, between: model.trip?.departureTime, and: model.trip?.arrivalTime)
        }
    }
    
}

#Preview {
    List {
        
    }
    .sheet(isPresented: .constant(true)) {
        VoyagelogForm(model: .preview(isActive: true))
    }
    .locationManager()
}
