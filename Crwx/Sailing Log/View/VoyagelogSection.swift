//
//  VoyagelogSection.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import SwiftData

struct VoyagelogSection: View {
    @State var model: VoyageLogViewModel
    //    let revertable: Bool
    //    @State private var sheetIsPresented = false
    //    @State private var confirmRevert = false
    @Environment(\.modelContext) private var context
    var body: some View {
        Group {
            
            // MARK: List of Events
            ForEach($model.events) { $event in
                EventLine(event: $event)
                    .swipeDeleteWithConfirmation("Delete Log Entry", message: "Would you like to delete this event?\nThis action cannot be undone.") {
                        model.events.removeAll {
                            $0.id == event.id
                        }
                    }
            }
            
            // MARK: New Event Button
            Group {
                if model.tripIsActive {
                    AddEventButton(events: $model.events, padded: model.isEmpty)
                        .swipeDeleteWithConfirmation("Delete All Log Entries", message: "Would you like to delete all events?\nThis action cannot be undone.") {
                            model.events = []
                        }
                } else if model.isEmpty {
                    Text("No Events")
                        .foregroundStyle(.secondary)
                        .padding(.vertical)
                }
            }
            .onChange(of: model.events) { oldValue, newValue in
                if newValue != oldValue {
                    model.sort()
                    model.save()
                    try? context.save()
                }
            }
        }
    }
}

#Preview {
    List {
        VoyagelogSection(model: .preview(isActive: true))
    }
    .locationManager()
    .preferredColorScheme(.dark)
}

