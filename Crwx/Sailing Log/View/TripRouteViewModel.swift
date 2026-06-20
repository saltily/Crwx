//
//  TripRouteViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/7/25.
//

import Foundation
import SwiftData
import FoundationSalt

struct TripRouteViewModel: Equatable {
    var start: UUID?
    var destination: UUID?
    var route: RouteSnippet?
}

extension TripRouteViewModel {
    init(trip: Trip, context: ModelContext) {
        // try to figure out the start of the trip, or go with last ending
        let start: Harbour?
        if let startHarbour = trip.startHarbour {
            start = startHarbour
        } else if let startCoordinate = trip.departureLocation?.coordinate ?? trip.route?.points.first?.coordinate {
            start = Harbour.at(location: startCoordinate, in: context)
        } else if let startLocation = trip.fetchPrevious(context)?.arrivalLocation {
            start = Harbour.at(location: startLocation, in: context)
        } else { start = nil }
        self.start = start?.id
        // and the end
        let end: Harbour?
        if let endHarbour = trip.endHarbour {
            end = endHarbour
        } else if let endCoordinate = trip.arrivalLocation?.coordinate ?? trip.route?.points.last?.coordinate {
            end = Harbour.at(location: endCoordinate, in: context)
        } else { end = nil }
        self.destination = end?.id
        // and the route [refresh asynchronously afterwards]
        self.route = trip.route
    }
    mutating func clear() {
        start = nil
        destination = nil
        route = nil
    }
    mutating func update(context: ModelContext) {
        // as in build a different route if we have new ends
    }
    func refreshRoute(container: ModelContainer) async throws -> RouteSnippet? {
        let actor = RouteLoader(modelContainer: container)
        let context = ModelContext(container)
        guard let start = Harbour.find(self.start, in: context)?.waypoint,
              let end = Harbour.find(self.destination, in: context)?.waypoint,
              route?.connects(start, to: end) != true
        else { throw E.KeepExistingRoute }
        return try await actor.route(from: start.persistentModelID, to: end.persistentModelID)
    }
    func validate(context: ModelContext) throws {
        let startHarbour = Harbour.find(start, in: context)
        let endHarbour = Harbour.find(destination, in: context)
        if start != nil,
           destination != nil
        {
            guard let startHarbour,
                  let endHarbour
            else { throw E.EndNotFound }
            guard let route,
                  route.connects(startHarbour, to: endHarbour)
            else { throw E.RouteDoesntConnect }
        }
        else if start != nil { // only start
            guard startHarbour != nil else { throw E.EndNotFound }
            guard route == nil else { throw E.MissingEnd }
        }
        else if destination != nil { // only end
            throw E.MissingEnd
        } else if route != nil { // only route
            throw E.RouteDoesntConnect
        }
    }
    enum E: Error {
        case KeepExistingRoute
        case DepartureLocked
        case MissingEnd
        case EndNotFound
        case ArrivalLocked
        case RouteDoesntConnect
    }
}


// MARK: Save
extension TripRouteViewModel {
    func save(to trip: Trip, in context: ModelContext) throws {
        try validate(context: context)
        let startHarbour = Harbour.find(start, in: context)
        let endHarbour = Harbour.find(destination, in: context)
        
        // don't change start if departed
        if let startHarbour {
            let departureOffset = trip.departureLocation?.distance(to: startHarbour).converted(to: .nauticalMiles).value ?? 100
            if trip.isDeparted {
                guard departureOffset < 0.25 else { throw E.DepartureLocked }
            }
            if departureOffset >= 0.25 {
                trip.departureLocation = .init(startHarbour)
            }
            trip.startHarbour = startHarbour
        }
        
        // don't change end if arrived
        if let endHarbour {
            let arrivalOffset = trip.arrivalLocation?.distance(to: endHarbour).converted(to: .nauticalMiles).value ?? 100
            if trip.isArrived {
                guard arrivalOffset < 0.25 else { throw E.ArrivalLocked }
            }
            if arrivalOffset >= 0.25 {
                trip.arrivalLocation = .init(endHarbour)
            }
            trip.endHarbour = endHarbour
        }
        
        // route should already be confirmed valid
        trip.route = route
        
    }
}
