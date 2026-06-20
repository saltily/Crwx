//
//  TripEditor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import SwiftData
import WxSalt
import FoundationSalt

struct TripEditor: View {
    @Bindable var trip: Trip
    @State private var isAutoloadingPredeparture = false
    @State private var autoloadError: Error?
    @Environment(\.modelContext) private var context
    var body: some View {
        let pre = trip.predeparture
        let baton = pre.fetchPrevious(context)
        List {
            Group {
                PredepartureButton(model: pre, isAutoloading: $isAutoloadingPredeparture, revertable: !trip.isDeparted)
                UnderwayButton(model: trip.departure, landing: .departure, revertable: !trip.isArrived && trip.events.isEmpty)
                    .environment(\.baton, baton)
                
                Section {
                    TripRouteRow(trip: trip)
                    if !trip.isArrived {
                        CommentsRow(value: $trip.comments, passengers: trip.passengers)
                    }
                    VoyagelogSection(model: trip.voyagelog)
                        .disabled(!trip.isDeparted)
                } header: {
                    HStack {
                        Text("Voyage")
                        Spacer()
                        if trip.isArrived {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .seaSection()
                
                UnderwayButton(model: trip.arrival, landing: .arrival, revertable: trip.postarrival.isEmpty)
                    .disabled(!trip.isDeparted)
                PostarrivalButton(model: trip.postarrival, revertable: true)
                    .disabled(!trip.isArrived)
            }
            .seaSection()
        }
        .environment(\.tripHasArrived, trip.hasArrived)
        .environment(\.tripMapper, trip.mapper)
        .listStyle(.grouped)
        .navigationTitle(
            trip.date.isToday ? "Today" :
                trip.date.isYesterday ? "Yesterday" :
                trip.date.formatted(.dateTime.month(.defaultDigits).day().year(.twoDigits))
        )
        .navigationBarTitleDisplayMode(.inline)
        // auto-load pre-departure if departed without doing it
        .onChange(of: trip.departureTime) { oldValue, newValue in
            if oldValue == nil,
               newValue != oldValue,
               trip.tidePredictions.isEmpty
            {
                autoloadPredeparture()
            }
        }
        .errorAlert(error: $autoloadError)
        .downloadCharts(trip)
    }
    
    private func autoloadPredeparture()
    {
        isAutoloadingPredeparture = true
        Task {
            var predeparture = trip.predeparture
            if predeparture.isEmpty {
                do {
                    try await predeparture.refresh(loc: trip.departureLocation, buoy: trip.departureObservation?.buoy, station: trip.departureTide?.station, context: context)
                    let p = predeparture
                    await MainActor.run {
                        trip.update(predeparture: p)
                        isAutoloadingPredeparture = false
                    }
                }
                catch {
                    await MainActor.run {
                        autoloadError = error
                        isAutoloadingPredeparture = false
                    }
                }
            }
            else {
                await MainActor.run {
                    isAutoloadingPredeparture = false
                }
            }
        }
    }
}

#Preview {
    let container = previewContainer
    let trip = Trip.preview()
    container.mainContext.insert(trip)
    return NavigationStack {
        TripEditor(trip: trip)
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
    .locationManager()
    .environment(WxEngine())
}

extension EnvironmentValues {
    struct TripHasArrivedKey: EnvironmentKey {
        static var defaultValue: Bool {
            return false
        }
    }
    var tripHasArrived: Bool {
        get { self[TripHasArrivedKey.self] }
        set { self[TripHasArrivedKey.self] = newValue }
    }
}

