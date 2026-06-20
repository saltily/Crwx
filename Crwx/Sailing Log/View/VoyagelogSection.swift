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


            
            //            .onDelete { indices in
            //                // probably confirm first
            //                model.events.remove(atOffsets: indices)
            //            }
            
            //            Button {
            //                sheetIsPresented = true
            //            } label: {
            //
            //
            //                // MARK: Content
            //                VStack(alignment: .leading) {
            //                    if model.isEmpty {
            //                        if model.tripIsActive {
            //                            Label("Log Event", systemImage: "camera")
            //                                .padding(.vertical)
            //                        }
            //                        else {
            //                            Text("No Events")
            //                                .foregroundStyle(.secondary)
            //                                .padding(.vertical)
            //                        }
            //                    }
            //                    else {
            //                        if model.tripIsActive {
            //                            Label("Log Event", systemImage: "camera")
            //                                .foregroundStyle(.accentColor)
            //                            Divider()
            //                        }
            //                        ForEach(0..<model.events.count, id: \.self) { i in
            //                            EventLine(event: model.events[i])
            //                            if i < (model.events.count - 1) {
            //                                Divider()
            //                            }
            //                        }
            ////                        switch model.events.count {
            ////                        case 0:
            ////                            EmptyView()
            ////                        case 1:
            ////                            EventLine(event: model.events.last!)
            ////                        default:
            ////                            EventLine(event: model.events.last!)
            ////                            Divider()
            ////                            EventLine(event: model.events[model.events.count-2])
            ////                            if model.events.count > 2 {
            ////                                Divider()
            ////                                Text("Plus \(model.events.count - 2) more")
            ////                                    .foregroundStyle(.secondary)
            ////                            }
            ////                        }
            //                    }
            //                }
            //                .frame(minHeight: 60)
            //
            //
            //            }
            //            .tint(model.isEmpty && model.tripIsActive ? .accentColor : .primary)
            //            .swipeActions(allowsFullSwipe: false) {
            //                if revertable && !model.isEmpty {
            //                    Button(systemImage: "trash") {
            //                        confirmRevert = true
            //                    }
            //                    .tint(.red)
            //                }
            //            }
            //            .confirmationDialog("Confirm Clear", isPresented: $confirmRevert) {
            //                Button("Delete All Events", role: .destructive) {
            //                    model.trip?.revertVoyageLog()
            //                }
            //                Button("Cancel", role: .cancel) {}
            //            } message: {
            //                Text("Would you like to delete all logged events?\nThis action cannot be undone.")
            //            }
            //            .sheet(isPresented: $sheetIsPresented, content: {
            //                VoyagelogForm(model: model)
            //                    .interactiveDismissDisabled()
            //                    .scrollDismissesKeyboard(.interactively)
            //            })
//        } header: {
//            HStack {
//                Text("Voyage Log")
//                Spacer()
//                if !model.tripIsActive {
//                    Image(systemName: "checkmark")
//                        .foregroundStyle(.green)
//                }
//            }
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

