//
//  TripEditor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI

struct TripEditor: View {
    @Bindable var trip: Trip
    @State private var isAutoloadingPredeparture = false
    @State private var autoloadError: Error?
    @Environment(\.modelContext) private var context
    @Environment(WxEngine.self) private var wx: WxEngine
    var body: some View {
        List {
            Group {
                PredepartureButton(model: trip.predeparture, isAutoloading: $isAutoloadingPredeparture, revertable: !trip.isDeparted)
                UnderwayButton(model: trip.departure, landing: .departure, revertable: !trip.isArrived && trip.events.isEmpty)
                VoyagelogButton(model: trip.voyagelog, revertable: true)
                    .disabled(!trip.isDeparted)
                UnderwayButton(model: trip.arrival, landing: .arrival, revertable: trip.postarrival.isEmpty)
                    .disabled(!trip.isDeparted)
                PostarrivalButton(model: trip.postarrival, revertable: true)
                    .disabled(!trip.isArrived)
            }
            .seaSection()
        }
        .listStyle(.grouped)
        .seaBackground()
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    wx.config.showVoyageLog = false
                } label: {
                    Image(systemName: "cloud.sun")
                        .frame(width: 40)
                }
            }
        }
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
