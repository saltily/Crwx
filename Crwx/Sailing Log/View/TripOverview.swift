//
//  TripOverview.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/15/25.
//

import SwiftUI
import FoundationUI
import WxSalt
import SwiftData
import FoundationSalt
import MapKit

struct TripOverview: View {
    @Bindable var trip: Trip
    @State private var goToStartHarbour = false
    @State private var goToEndHarbour = false
    var body: some View {
        List {
            // MARK: Map
            Section {
                ZStack {
                    SaltMap {
                        MapDot(trip.timestampedDepartureLocation, tint: .black.opacity(0.5))
                        MapDot(trip.timestampedArrivalLocation)
                        if let route = trip.route {
                            Polyline(route.points, tint: .gray, thickness: 2)
                        }
                        if let track = trip.track {
                            Polyline(track.points)
                        }
                    }
                    .northUp()
                    .initialZoom(1.6)
                    TripMapOverlays(trip: trip)
                }
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .listRowBackground(Color.clear)
                .listRowInsets(.init())
            } header: {
                HStack {
                    ForecastConditionsSymbol(forecast: trip.localForecast)
                    if let highTemperature = trip.localForecast?.highTemperature {
                        let s = highTemperature.formatted(.number.precision(.fractionLength(0)))
                        Text("\(s)º")
                    }
                    Spacer()
                    Text(trip.passengers)
                }
                .textCase(.none)
            } footer: {
                if let fathoms = trip.fathoms {
                    VStack(alignment: .leading) {
                        if let scope = trip.scope,
                           let maximumSwing = trip.maximumSwing,
                           let depthRange = trip.depthRange
                        {
                            Text("\(scope) scope with a swing radius of \(maximumSwing.rounded) ft.")
                            Text("\(fathoms.formatted(.number.precision(.fractionLength(0...1)))) fathoms out in \(depthRange) of water.")
                        } else {
                            Text("\(fathoms.formatted(.number.precision(.fractionLength(0...1)))) fathoms out.")
                        }
                    }
                    .font(.caption)
                }
            }
            
            // MARK: Sections
            TripNotesSection(trip: trip)
//            TripHarboursSection(harbours: [trip.startHarbour, trip.endHarbour].compactMap { $0 }.orderedSet.array)
            TripStatsTable(trip: trip, goToStartHarbour: $goToStartHarbour, goToEndHarbour: $goToEndHarbour)
            TideTableSection(predictions: trip.tidePredictions)
            MarineForecastSection(forecast: trip.marineForecast, observation: trip.buoyObservation)
            LocalForecastSection(forecast: trip.localForecast)
        }
//        .editSheet(trip)
        .navigationTitle(trip.date.formatted(.dateTime.month().day().year().weekday()))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $goToStartHarbour) {
            if let startHarbour = trip.startHarbour {
                HarbourDetail(harbour: startHarbour)
            }
        }
        .navigationDestination(isPresented: $goToEndHarbour) {
            if let endHarbour = trip.endHarbour {
                HarbourDetail(harbour: endHarbour)
            }
        }
        .toolbar {
            ToolbarItem {
                NavigationLink(destination: TripEditor(trip: trip).seaBackground()) {
                    Text("Edit")
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
        TripOverview(trip: trip)
            .seaBackground()
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
    .locationManager()
    .environment(WxEngine())
}
