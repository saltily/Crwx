//
//  UnderwayFetchRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import CoreLocation
import WxSalt

struct UnderwayFetchRow: View {
    @Binding var model: UnderwayViewModel
    let landing: UnderwayButton.Landing
    @PositionTracker private var tracker
    @Environment(\.tripHasArrived) private var hasArrived
    @Environment(\.modelContext) private var context
    @Environment(\.baton) private var baton
    var body: some View {
        Section {
            NavigationLink(destination: UnderwayFetchDetail(model: $model, landing: landing)) {
                VStack(alignment: .leading, spacing: 8) {
                    
                    // Location
                    HStack {
                        if refreshingLocation {
                            ProgressView()
                        }
                        else {
                            LocationLine(location: model.location)
                        }
                    }
                    .frame(height: 120)
                    Divider()
                        .padding(.vertical, 5)
                    
                    // Buoy
                    if refreshingObservation {
                        ProgressView()
                    }
                    else {
                        BuoyLine(observation: model.observation)
                    }
                    
                    // Tide
                    if refreshingTide {
                        ProgressView()
                    }
                    else {
                        HStack {
                            Text("Height of Tide")
                            Spacer()
                            if let height = model.tide?.height {
                                Text(height, format: .number.precision(.fractionLength(0...1))) + Text(" ft")
                            }
                        }
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
            if let time = model.time {
                HStack {
                    Text(time, format: .dateTime.hour().minute())
                    Spacer()
                    if (time.isToday) {
                        Text("Today")
                    } else if (time.isYesterday) {
                        Text("Yesterday")
                    } else if (Date.now.timeIntervalSince(time) < 5.day) {
                        Text(time, format: .dateTime.weekday(.wide))
                    }
                    else {
                        Text(time, format: .dateTime.weekday(.wide).month().day().year())
                    }
                }
            }
        } footer: {
            VStack(alignment: .leading) {
                if let observation = model.observation {
                    HStack(spacing: 3) {
                        Text("Weather Buoy")
                        Text(observation.date, format: .dateTime.hour().minute())
                        Spacer()
                        Text(observation.buoy?.name ?? "--")
                    }
                }
                if let station = model.tide?.station {
                    HStack {
                        Text("Tide Station")
                        Spacer()
                        Text(station.name)
                    }
                }
            }
        }
        .onAppear {
            if !model.isLoaded {
                refresh(forcing: false)
            } else if model.chartDepth == nil {
                model.chartDepth = baton?.chartDepth
            }
        }
        .errorAlert(error: $refreshError)
    }
    
    
    
    // MARK: - Refresh
    @State private var refreshingLocation = false
    @State private var refreshingTide = false
    @State private var refreshingObservation = false
    @State private var refreshError: Error?
    private func refresh(forcing: Bool = true) {
        Task {
            
            
            // MARK: Time
            // not for arrival
            // for departure only if forcing, not arrived, and no logged events
            let changeTheTime: Bool =
            if landing == .departure,
               forcing,
               model.trip?.events.count == 0,
               model.trip?.isArrived == false
            { true } else { false }
            if changeTheTime {
                model.time = model.trip?.valid(departureTime: .now) ?? .now
            }
            
            
            // MARK: Location
            let loc: CLLocation? = await tracker.currentLocation // ?? .randomOnCoastOfMaine()
            var updateCoordinates = false
            var refreshLocation: Bool
            if hasArrived {
                refreshLocation = false // if we started from a track, don't mess with the locations
            } else {
                switch landing {
                case .departure:
                    // never if trip previously departed
                    if model.trip?.departureTime != nil
                    {
                        refreshLocation = false
                    }
                    else if forcing {
                        refreshLocation = true
                    }
                    else if let location = model.location
                    {
                        // always update coordinates if first departing
//                        updateCoordinates = true
                        // if the trip is today and we're within 500 feet of anticipated start, then let's refine that
                        if let loc,
                           model.time?.isToday != false,
                           loc.distance(to: location).converted(to: .feet).value < 500
                        {
                            updateCoordinates = true
                            refreshLocation = false
                        }
//                        // only refresh the location if more than 0.25 mile away and the trip is today
//                        if let loc,
//                           loc.distance(to: location).converted(to: .nauticalMiles).value > 0.25,
//                           model.time?.isToday != false
//                        {
//                            refreshLocation = true
//                        }
                        else {
                            updateCoordinates = false
                            refreshLocation = false
                        }
                    }
                    // if never set, definitely
                    else {
                        refreshLocation = true
                    }
                case .arrival:
                    // always when forcing
                    if forcing {
                        refreshLocation = true
                    }
                    // always when not previously arrived
                    else if model.trip?.arrivalTime == nil
                    {
                        refreshLocation = true
                    }
                    // let it stay missing if arrived
                    else {
                        refreshLocation = false
                    }
                }
            }
            if refreshLocation {
                // don't reuse the old buoy and tide station
                model.suggestedBuoy = nil
                model.suggestedTideStation = nil
                refreshingLocation = true
                do {
                    let newLocation = try await LocationSnippet(loc, in: context.container)
                    model.location = newLocation
                    refreshingLocation = false
                }
                catch {
                    refreshError = error
                    refreshingLocation = false
                }
            }
            else if updateCoordinates,
                    let loc
            {
                model.location = .init(name: model.location?.name ?? "", latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
            }
            if model.harbourId == nil,
               let location = model.location
            {
                model.harbourId = Harbour.at(location: location, in: context)?.id
            }

            
            do {
                
                // MARK: Chart Depth
                if let chartDepth = baton?.chartDepth,
                   model.chartDepth == nil
                {
                    model.chartDepth = chartDepth
                }
                
                // MARK: Tide
                // if missing, do it
                // if time or location changed, do it
                let locationChangedALot: Bool =
                if !refreshLocation { false }
                else if let loc,
                        let oldStation = model.tide?.station?.id {
                    oldStation != TideStation.all.nearest(to: loc)?.value.id
                } else { true }
                if model.tide == nil ||
                    changeTheTime || locationChangedALot
                {
                    await MainActor.run {
                        refreshingTide = true
                    }
                    let newTide = try await model.fetchTide(at: loc)
                    await MainActor.run {
                        model.tide = newTide
                        model.predictedTidalCurrent = newTide?.predictedCurrent ?? ""
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
            do {
                
                // MARK: Buoy
                // if missing, do it
                // if time or location changed, do it
                let locationChangedALot: Bool =
                if !refreshLocation { false }
                else if let loc,
                        let oldBuoy = model.observation?.buoy?.id {
                    oldBuoy != MarineBuoy.offshore.nearest(to:loc)?.value.id
                } else { true }
                if model.observation == nil ||
                    changeTheTime || locationChangedALot
                {
                    await MainActor.run {
                        refreshingObservation = true
                    }
                    let newWx = try await model.fetchObservation(near: loc)
                    let tooNew: Bool =
                    if let captured = newWx?.date,
                       let arrived = model.time
                    {
                        captured.timeIntervalSince(arrived) > 1.hour
                    } else { false }
                    await MainActor.run {
                        if !tooNew {
                            model.observation = newWx
                        }
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
            do {
                
                // MARK: Wind
                // if missing, do it
                if model.windSpeed == nil {
                    // note that this won't work if trying to depart on a trip that was pre-departed on a different day
                    if let currentWind = try await model.fetchCurrentWind(at: loc) {
                        await MainActor.run {
                            model.predictedWindSpeed = currentWind.speed.lowerBound
                            model.windDirection = currentWind.direction
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            UnderwayFetchRow(model: .constant(.preview()), landing: .departure)
        }
    }
    .locationManager()
}
