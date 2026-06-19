//
//  PredepartureFetchRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import CoreLocation
import WxSalt

struct PredepartureFetchRow: View {
    @Binding var model: PreDepartureViewModel
    @Environment(\.modelContext) private var context
    var body: some View {
        Section {
            NavigationLink(destination: PredepartureFetchDetail(model: $model)) {
                VStack(alignment: .leading, spacing: 8) {
                    
                    // location
                    if refreshingLocation {
                        ProgressView()
                    }
                    else {
                        HStack {
                            if let location = model.localForecast?.point {
                                Text(location.name ?? "No name")
                                Spacer()
                                Text(location.coordinate, format: .location.minutes().precision(.fractionLength(1)))
                                    .foregroundStyle(.secondary)
                            }
                            else {
                                Text("No location")
                            }
                        }
                    }
                    Divider()
                    
                    // tide
                    if refreshingTide {
                        ProgressView()
                    }
                    else {
                        TidePredictionLine(predictions: model.tidePredictions)
                            .foregroundColor(.secondary)
                    }
                    
                    // local weather
                    if refreshingLocalForecast {
                        ProgressView()
                    }
                    else {
                        LocalForecastLine(forecast: model.localForecast)
                    }
                    
                    // marine weather
                    if refreshingMarineForecast {
                        ProgressView()
                    }
                    else {
                        MarineForecastLine(forecast: model.marineForecast)
                    }
                    
                    // buoy
                    if refreshingObservation {
                        ProgressView()
                    }
                    else {
                        BuoyLine(observation: model.buoyObservation)
                    }
                    
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(systemImage: "arrow.clockwise") {
                    refresh()
                }
                .tint(.accentColor)
            }
        } header: {
            if (model.date.isToday) {
                Text("Today")
            } else if (model.date.isYesterday) {
                Text("Yesterday")
            } else if (Date.now.timeIntervalSince(model.date) < 5.day) {
                Text(model.date, format: .dateTime.weekday(.wide))
            }
            else {
                Text(model.date, format: .dateTime.weekday(.wide).month().day().year())
            }
        } footer: {
            VStack(alignment: .leading) {
                if let station = model.tidePredictions.first?.station {
                    HStack {
                        Text("Tide Station")
                        Spacer()
                        Text(station.name)
                            .lineLimit(1)
                    }
                }
                if let location = model.localForecast?.point,
                   model.localForecast?.hasSomething == true
                {
                    HStack(spacing: 3) {
                        Text("Local Wx")
                        if let time = model.localForecast?.date {
                            Text(time, format: .dateTime.hour().minute())
                        }
                        Spacer()
                        LocationView { currentLocation in
                            Text(location.relativeSentence(from: currentLocation))
                        }
                    }
                }
                if let zone = model.marineForecast?.zone {
                    HStack(spacing: 3) {
                        Text("Marine Wx")
                        if let time = model.marineForecast?.date {
                            Text(time, format: .dateTime.hour().minute())
                        }
                        Spacer()
                        Text(zone.name)
                            .lineLimit(1)
                    }
                }
                if let observation = model.buoyObservation {
                    HStack(spacing: 3) {
                        Text("Wx Buoy")
                        Text(observation.date, format: .dateTime.hour().minute())
                        Spacer()
                        Text(observation.buoy?.name ?? "--")
                    }
                }
            }
        }
        .onAppear {
            if !model.isLoaded {
                // pop out of the run loop before refreshing to give the location manager a chance to cache the current location
                Task {
                    await MainActor.run {
                        refresh(forcing: false)
                    }
                }
            }
        }
        .errorAlert(error: $refreshError)
    }
    
    
    
    
    // MARK: - Refresh
    @State private var refreshingLocation = false
    @State private var refreshingTide = false
    @State private var refreshingLocalForecast = false
    @State private var refreshingMarineForecast = false
    @State private var refreshingObservation = false
    @State private var refreshError: Error?
    @PositionTracker private var tracker
    private func refresh(forcing: Bool = true) {
        
        // MARK: Date
        // don't update date on legacy trip, so must be newest trip
        // update date if not departed, except don't auto-update the date if we have been previously loaded
//        if model.departureTime == nil,
//           forcing || model.isEmpty
//        {
//            model.date = .now
//        }
        let tooFarInFuture: Bool =
        if let departed = model.departureTime {
            Date.now.timeIntervalSince(departed) > 1.hour
        } else { false }
        
        // MARK: Odometer, Fuel
        let baton = model.fetchPrevious(context)
        if model.odometer == nil { model.odometer = baton?.odometer }
        if model.fuel == nil { model.fuel = baton?.fuel }
        if model.departureLocation == nil { model.departureLocation = baton?.location }
        if model.anchorage == nil {
            model.anchorage = baton?.harbour
            model.anchorageHighlights = baton?.harbour?.protectionHighlights ?? ""
            model.anchorageNotes = baton?.harbour?.notes ?? ""
        }
        if let lastFuel = try? context.fetchOne(.lastSounding(of: .fuel)) {
            if let departureTime = model.departureTime,
               lastFuel.date > departureTime
            { } // just stick with the baton fuel
            else { model.fuel = .init(gallons: lastFuel.value) }
        }
        if !forcing, // first time
           let baton,
           !baton.isHome
        {
            if model.passengers.isEmpty { model.passengers = baton.passengers }
            if model.dinghy == .none { model.dinghy = baton.dinghy }
//            logger.log("And the chart depth last time we were here was \(describing(baton.chartDepth))")
        }
        Task {
            
            
            // MARK: Location
            // should we update the location?
            // if there is a departure location use that
            // if we've been updated before and we know that location, use that
            let location: LocationSnippet? =
            if model.departureTime != nil,
               let location = model.departureLocation
            {
                location
            }
            else if //!forcing, // don't force location change from this page - drill deeper for that
                    let location = model.localForecast?.point
            {
                location
            }
            else if let lastLocation = baton?.location {
                lastLocation
            }
            else { nil }
            var loc: CLLocation? = location?.clLocation
            if loc == nil {
                loc = await tracker.currentLocation
            }
            
            // location & local
            do {
                
                // name the location if we're doing a new one
                let newLocation: LocationSnippet? =
                if let location {
                    location
                } else {
                    try await .init(loc, in: context.container)
                }
                let locationChangedALot: Bool =
                if let oldLocation = model.localForecast?.point {
                    oldLocation.distance(to: newLocation).converted(to: .nauticalMiles).value > 0.25
                } else { false }
                
                // MARK: Local Forecast
                
                // never if too far in future
                // always if location has changed a lot
                // else forcing or not previously fetched
                if let newLocation,
                   !tooFarInFuture,
                   locationChangedALot || forcing || model.localForecast == nil
                {
                    await MainActor.run {
                        refreshingLocation = true
                        refreshingLocalForecast = true
                    }
                    let newWx = try await ForecastSnippet.fetchLocal(for: newLocation, at: model.date)
                    await MainActor.run {
                        model.localForecast = model.localForecast?.updating(with: newWx) ?? newWx
                        refreshingLocation = false
                        refreshingLocalForecast = false
                    }
                }
            }
            catch {
                await MainActor.run {
//                    refreshError = error
                    refreshingLocation = false
                    refreshingLocalForecast = false
                    // if well into the future, remove the local forecast
                    // but we need to keep this as the only reference to the location
                    if model.date.timeIntervalSinceNow > 9.day {
                        model.localForecast = .init(date: model.date, point: location ?? .zero, winds: [])
                    }
                }
            }
            // tide
            do {
                
                // MARK: Tide Predictions
                // if the day has changed
                // if the location has changed quite a bit
                // if never done
                let dayHasChanged: Bool =
                if let oldDay = model.tidePredictions.first?.date.withoutTime {
                    oldDay != model.date.withoutTime
                } else { false }
                let locationChangedALot: Bool =
                if let loc,
                   let oldStation = model.tidePredictions.first?.station?.id {
                    oldStation != TideStation.all.nearest(to: loc)?.value.id
                } else { false }
                if dayHasChanged || locationChangedALot || model.tidePredictions.isEmpty {
                    await MainActor.run {
                        refreshingTide = true
                    }
                    let newPredictions = try await model.fetchTide(at: loc)
                    await MainActor.run {
                        model.tidePredictions = newPredictions
                        refreshingTide = false
                    }
                }
            }
            catch {
                await MainActor.run {
                    refreshError = error
                    refreshingTide = false
                }
            }
            // buoy
            do {
                
                // MARK: Buoy Observation
                // never if too far in future
                // always if location has changed a lot
                // else forcing or not previously fetched
                let locationChangedALot: Bool =
                if let loc,
                   let oldBuoy = model.buoyObservation?.buoy?.id {
                    oldBuoy != MarineBuoy.offshore.nearest(to: loc)?.value.id
                } else { false }
                if !tooFarInFuture,
                   locationChangedALot || forcing || model.buoyObservation == nil
                {
                    await MainActor.run {
                        refreshingObservation = true
                    }
                    var newWx = try await model.fetchObservation(near: loc)
                    if let d = newWx?.date,
                       model.date.timeIntervalSince(d) > 8.hour
                    {
                        newWx = nil
                    }
                    await MainActor.run {
                        model.buoyObservation = newWx
                        refreshingObservation = false
                    }
                }
            }
            catch {
                await MainActor.run {
                    refreshError = error
                    refreshingObservation = false
                }
            }       
            // marine
            do {
                
                // MARK: Marine Forecast
                // never if too far in future
                // always if location has changed a lot
                // else forcing or not previously fetched
                let locationChangedALot: Bool =
                if let loc,
                   let oldZone = model.marineForecast?.zone?.id {
                    oldZone != MarineZone.active.nearest(to: loc)?.value.id
                } else { false }
                if !tooFarInFuture,
                   locationChangedALot || forcing || model.marineForecast == nil
                {
                    await MainActor.run {
                        refreshingMarineForecast = true
                    }
                    let newWx = try await model.fetchMarineForecast(for: loc)
                    await MainActor.run {
                        model.marineForecast = newWx
                        refreshingMarineForecast = false
                    }
                }
            }
            catch {
                await MainActor.run {
                    refreshError = error
                    refreshingMarineForecast = false
                }
            }
        }
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        Form {
            PredepartureFetchRow(model: .constant(.preview()))
        }
    }
    .preferredColorScheme(.dark)
    .locationManager()
}
