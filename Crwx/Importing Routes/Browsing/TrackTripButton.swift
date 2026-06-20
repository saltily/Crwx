//
//  TrackTripButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/10/25.
//

import SwiftUI
import FoundationUI
import FoundationSalt

struct TrackTripButton: View {
    @Bindable var track: Track
    @Environment(\.modelContext) private var context
    @State private var tripToEdit: Trip?
    @State private var isLoading = false
    @State private var error: Error?
    var body: some View {
        // use a ZStack so the sheet stays attached regardless of the state of the conditional content
        ZStack {
            if let trip = track.trip {
                NavigationLink(destination: TripOverview(trip: trip).seaBackground()) {
                    Image(systemName: "book.pages.fill")
                }
            } else if isLoading {
                ProgressView()
            } else {
                Button(systemImage: "link.badge.plus") {
                    Task {
                        do {
                            isLoading = true
                            try await makeTrip()
                            isLoading = false
                        } catch {
                            logger.critical("Couldn't make trip: \(error)")
                            isLoading = false
                            self.error = error
                        }
                    }
                }
            }
        }
        .errorAlert(error: $error)
        .fullScreenCover(item: $tripToEdit) { trip in
            NavigationStack {
                TripEditor(trip: trip)
                    .seaBackground(.darkSeaBlue)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            DismissButton("Cancel") {
                                context.delete(trip)
                                try? context.save()
                                return true
                            }
                        }
                        ToolbarItem {
                            DismissButton("Save")
                                .fontWeight(.bold)
                        }
                    }
            }
        }
    }
}


// MARK: Making the Trip
extension TrackTripButton {
    private func makeTrip() async throws {
        guard let date = track.date else { throw TrackTripError.NoDate }
        guard var start = track.start,
              var end = track.end
        else { throw TrackTripError.MissingEndpoint }
        let new = Trip()
        new.date = date
        
        // 1. Name the start and end locations.
        try await start.fetchName(in: context.container)
        try await end.fetchName(in: context.container)
        new.departureLocation = start
        new.arrivalLocation = end

        // 2. We know the basic miles made good, and sometimes the average speed.
        new.milesMadeGood = track.distance
        new.averageSpeed = track.averageSpeed
        
        // 3. Establish start and end times if we can.
        let points = track.points
        let firstPoint = points.first
        let lastPoint = points.last
        new.departureTime = firstPoint?.time
        new.arrivalTime = lastPoint?.time

        // 4. Lookup the tides and weather for the day.
        let predeparture = new.predeparture
        let baton = predeparture.fetchPrevious(context)
        new.odometerStart = baton?.odometer
        new.fuelStart = baton?.fuel
        new.odometerEnd = baton?.odometer?.adding(track.distance.rounded)
        let loc = start.clLocation
        new.tidePredictions = (try? await predeparture.fetchTide(at: loc)) ?? []
        new.localForecast = try? await .fetchLocal(for: loc, at: new.departureTime ?? date)
        new.localForecast?.point?.name = start.name
        new.marineForecast = try? await predeparture.fetchMarineForecast(for: loc) // won't work
        new.buoyObservation = try? await predeparture.fetchObservation(near: loc) // won't work
        
        // 5. Attempt to lookup tide and buoy at time of departure and arrival
        if firstPoint?.time != nil {
            let departure = new.departure
            new.departureTide = try? await departure.fetchTide(at: loc)
            new.departureTidalCurrent = new.departureTide?.predictedCurrent ?? ""
            new.departureObservation = try? await departure.fetchObservation(near: loc) // won't work
        }
        if lastPoint?.time != nil {
            let arrival = new.arrival
            new.arrivalTide = try? await arrival.fetchTide(at: end.clLocation)
            new.arrivalTidalCurrent = new.arrivalTide?.predictedCurrent ?? ""
            new.arrivalObservation = try? await arrival.fetchObservation(near: end.clLocation) // won't work
        }
        
        // 6. Need to get it in the context before establishing relationships
        context.insert(new)
        try context.save()
        
        // 7. Now we can relate it to the track
        new.track = track
        track.trip = new
        try context.save()
        
        // 8. Now we can pop up the editor to customise, or give up and delete
        tripToEdit = new
    }
    enum TrackTripError: Error {
        case NoDate
        case MissingEndpoint
    }
}
