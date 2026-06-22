//
//  PostarrivalButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import WxSalt
import FocusOnAppear

struct PostarrivalButton: View {
    let model: PostArrivalViewModel
    let revertable: Bool
    @State private var sheetIsPresented = false
    @State private var confirmRevert = false
    var body: some View {
        Section {
            Button {
                sheetIsPresented = true
            } label: {
                
                
                // MARK: Content
                VStack(alignment: .leading, spacing: 8) {
                    if model.isEmpty {
                        Label("Complete Trip", systemImage: "pencil.and.list.clipboard")
                            .padding(.vertical)
                    }
                    else {
                        HStack {
                            if let odometer = model.odometer {
                                let s = odometer.formatted(.number.grouping(.never))
                                Text("\(s) nm")
                            }
                            Spacer()
                            if let fuel = model.fuel,
                               let inches = fuel.inches
                            {
                                Text("\(inches.eighths) in")
                                let s = (fuel.gallons ?? 0).formatted(.number.precision(.fractionLength(1)))
                                Text("\(s) gals")
                            }
                        }
                        .foregroundColor(.secondary)
                        HStack {
                            Text("MMG")
                                .padding(.trailing, 15)
                                .foregroundStyle(.primary)
                            Spacer()
                            if let milesMadeGood = model.milesMadeGood {
                                let s = milesMadeGood.formatted(.number.precision(.fractionLength(0...1)))
                                Text("\(s) nm")
                            }
                            Text("Duration")
                                .padding(.leading, 10)
                                .foregroundStyle(.primary)
                            Spacer()
                            if let duration = model.duration {
                                Text(duration, format: .duration.driving)
                            }
                        }
                        .foregroundStyle(.secondary)
                        HStack {
                            Text("SOG avg")
                                .foregroundStyle(.primary)
                            Spacer()
                            if let averageSpeed = model.averageSpeed {
                                let s = averageSpeed.formatted(.number.precision(.fractionLength(0...1)))
                                Text("\(s) kts")
                            }
                            Text("SOG max")
                                .padding(.leading, 10)
                                .foregroundStyle(.primary)
                            Spacer()
                            if let maximumSpeed = model.maximumSpeed {
                                let s = maximumSpeed.formatted(.number.precision(.fractionLength(0...1)))
                                Text("\(s) kts")
                            }
                        }
                        .foregroundStyle(.secondary)
                        if let fathoms = model.fathoms {
                            Divider()
                            HStack {
                                Text("Rode")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("\(fathoms) ftm")
                                Text("Depth")
                                    .padding(.leading, 10)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if let depthRange = model.depthRange {
                                    Text(depthRange)
                                }
                            }
                            .foregroundStyle(.secondary)
                            HStack {
                                Text("Scope")
                                    .foregroundStyle(.primary)
                                Spacer()
                                if let scope = model.scope {
                                    Text(scope)
                                }
                                Text("Swing")
                                    .padding(.leading, 10)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if let maximumSwing = model.maximumSwing {
                                    Text("\(maximumSwing.rounded) ft")
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                
                
            }
            .tint(model.isEmpty ? .accentColor : .primary)
            .swipeActions(allowsFullSwipe: false) {
                if revertable && !model.isEmpty {
                    Button(systemImage: "trash") {
                        confirmRevert = true
                    }
                    .tint(.red)
                }
            }
            .swipeActions(edge: .leading) {
                if let trip = model.trip {
                    Button {
                        trip.forceCompletion.toggle()
                    } label: {
                        Image(systemName: "checkmark")
                            .symbolVariant(trip.forceCompletion ? .fill.circle : .circle)
                    }
                    .tint(.teal)
                }
            }
            .confirmationDialog("Confirm Clear", isPresented: $confirmRevert) {
                Button("Clear Post-Arrival Data", role: .destructive) {
                    model.trip?.revertPostArrival()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Would you like to clear post-arrival data?\nThis action cannot be undone.")
            }
            .sheet(isPresented: $sheetIsPresented, content: {
                PostarrivalForm(model: model)
                    .interactiveDismissDisabled()
                    .scrollDismissesKeyboard(.interactively)
            })
            
            if let trip = model.trip,
               trip.isArrived
            {
                CommentsButton(trip: trip, passengers: model.passengers)
                PickPhotosButton(trip: trip)
                if let track = trip.track,
                   let depart = trip.departureTime,
                   let arrive = trip.arrivalTime
                {
                    WhereWasIButton(start: depart, end: arrive, track: track.points)
                }
            }


        } header: {
            HStack {
                Text("Post-Arrival")
                Spacer()
                if model.isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                }
                else {
                    Image(systemName: "cellularbars", variableValue: model.percentComplete)
                }
            }
        }
    }
}

#Preview {
    List {
        PostarrivalButton(model: .preview(), revertable: true)
    }
    .locationManager()
    .preferredColorScheme(.dark)
}

fileprivate struct CommentsButton: View {
    @Bindable var trip: Trip
    let passengers: String
    @State private var isPresented = false
    @State private var text: String = ""
    var body: some View {
        Button {
            text = trip.comments
            isPresented = true
        } label: {
            PlaceholderText("\"\(trip.comments.trimmingRight(in: .whitespacesAndNewlines))\"", placeholder: "Add Comments…")
                .foregroundStyle(.secondary)
        }
        .tint(.primary)
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                List {
                    Section {
                        TextField("Comments", text: $text, axis: .vertical)
                            .lineLimit(5...)
                            .focusOnAppear()
                    } footer: {
                        Text(passengers)
                    }
                    .seaSection()
                }
                .seaBackground(.flat)
                .navigationTitle("Comments")
                .navigationBarTitleDisplayMode(.inline)
                .cancelButton()
                .saveButton {
                    trip.comments = text
                }
            }
        }
    }
}
