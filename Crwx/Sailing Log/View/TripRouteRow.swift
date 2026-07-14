//
//  TripRouteRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/5/25.
//

import SwiftUI
import FoundationSalt
import FoundationUI
import WxSalt
import SwiftData
import os

/// Should be 4 phases.
/// 1. No route set.  Navigate to select start and end.
/// 2. Route set but trip not started.  See the route and how many miles it will be.  Also can show the general arrow direction.  Also can drill to details about the harbours.  If there is a map at all, just a little icon that's not pannable.  Drill for more.  Can edit both start and end.
/// 3. Route set and trip underway.  Here we get the RosePoint stuff.  DTG, TTG, ETA.  Percent complete.  MMG.  Average speed.  Time lapsed.  Needs to know our current location and time.  Can edit the end and will establish the starting time and position (can't change those).
/// 4. Trip completed = route finalised.  Not editable.  Final stats.  Basically links through to trip overview.
struct TripRouteRow: View {
    @Bindable var trip: Trip
    @State private var isPresented = false
    @State private var model: TripRouteViewModel = .init()
    @Environment(\.modelContext) private var context
    @State private var anchorageSetter: TripDestinationPicker.Destination = .init()
    var body: some View {
        
        switch state {
            // MARK: 1. Needs Route
        case .needsRoute, .waitingToSail:
            Button {
                // setup the model
                model = .init(trip: trip, context: context)
                isPresented = true
                refreshRoute()
            } label: {
                
                Label {
                    // MARK: 2. Waiting to Sail
                    if let route = trip.route {
                        HStack {
                            Text(route.name)
                            Spacer()
                            Group {
                                let s = route.distance.formatted(.number.precision(.fractionLength(0...1)))
                                Text("\(s) nm")
                                if let bearing = route.bearing {
                                    Image(systemName: "location.north.fill")
                                        .rotationEffect(.degrees(bearing.converted(to: .degrees).value))
                                        .frame(height: 20)
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                        .tint(.primary)
                    }
                    else {
                        Text("Set Route")
                    }
                } icon: {
                    Image(systemName: "pencil.and.scribble")
                }

            }
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    TripRouteForm(model: $model)
                        .seaBackground(.flat)
                        .cancelButton()
                        .saveButton {
                            try model.save(to: trip, in: context)
                            try context.save()
                        }
                }
            }

            // MARK: 3. Sailing
        case .sailing:
            SailingSnapshotRow(start: trip.departureTime, route: trip.route, startHarbour: trip.startHarbour, endHarbour: trip.endHarbour)
                .onAppear {
                    anchorageSetter.save = { anchorage in
                        do {
                            try set(anchorage: anchorage)
                        } catch {
                            logger.critical("Error trying to set anchorage: \(error)")
                        }
                    }
                }
                .environment(\.anchorageSetter, anchorageSetter)
            
            // MARK: 4. Arrived
        case .arrived:
            Text("Completed route.")
            // in the event that a trip was completed with a bogus route, this will let us refresh to a decent route.
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button(systemImage: "arrow.clockwise") {
                        Task {
                            do {
                                model = .init(trip: trip, context: context)
                                model.route = try await model.refreshRoute(container: context.container)
                                try model.save(to: trip, in: context)
                                try context.save()
                            } catch {
                                logger.critical("Couldn't refresh the route: \(error)")
                            }
                        }
                    }
                    .tint(.accentColor)
                }
        }
        
    }
    private func refreshRoute() {
        let container = context.container
        Task {
            do {
                model.route = try await model.refreshRoute(container: container)
            } catch {
                // it's fine if we don't - throws if doesn't need updating
                logger.trace("Not updating the route: \(error)")
            }
        }
    }
    enum RouteState {
        case needsRoute, waitingToSail, sailing, arrived
    }
    private var state: RouteState {
        if trip.route == nil || trip.endHarbour == nil { return .needsRoute }
        if trip.isArrived { return .arrived }
        if trip.isDeparted { return .sailing }
        return .waitingToSail
    }
    private func set(anchorage: AnchoragePotential) throws {
        guard let endHarbour = Harbour.find(anchorage.destination, in: context)
        else { throw PotentialAnchorages.Engine.E.BadId }
        trip.arrivalLocation = .init(endHarbour)
        trip.endHarbour = endHarbour
        trip.route = anchorage.route
        try context.save()

        // and potentially sort out the cruise
        if let cruise = trip.cruise,
           let i = cruise.legs.firstIndex(where: {
               $0.trip_id == trip.id
           })
        {
            let vm = try cruise.viewModel(in: context)
            vm.move(i, to: endHarbour)
            cruise.update(model: vm)
            try context.save()
        }
        
    }
}
