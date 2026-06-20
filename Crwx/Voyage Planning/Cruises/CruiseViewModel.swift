//
//  CruiseViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import Foundation
import FoundationSalt
import FoundationUI
import SwiftData
import CoreLocation
import MapKit
import WxSalt

/// The basic idea on this is so that we can look at a whole cruise at once.
/// Look at it before, during, and after.
@Observable
final class CruiseViewModel: Identifiable {
    let id: UUID
    private(set) var anchorages: [Anchorage] = []
    private(set) var start: Day = .today
    private(set) var legs: [Leg] = []
    /// So we know how old the wind snippets are
    var forecastFetched: Date?
    var colours: ColorPattern.Family = .red

    init(modelContainer: ModelContainer) {
        self.routeLoader = .init(modelContainer: modelContainer)
        self.id = UUID()
    }
    fileprivate init(modelContainer: ModelContainer, id: UUID = .init(), start: Day = .today, weather: CruiseWeather = .init(), anchorages: [Anchorage] = [], legs: [Leg] = []) {
        self.routeLoader = .init(modelContainer: modelContainer)
        self.id = id
        self.start = start
        self.weather = weather
        self.anchorages = anchorages
        self.legs = legs
    }
    private let routeLoader: RouteLoader
    private let forecasts = CoastalForecasts()
    private(set) var weather = CruiseWeather()
}
extension CruiseViewModel {
    /// Helps to convert a day into a colour in a colour pattern
    subscript(day: Day) -> Int {
        day.days(since: start)
    }
    var region: MKCoordinateRegion {
        if anchorages.count == 1 {
            return .init(center: anchorages[0], diameter: .init(value: 30, unit: .nauticalMiles))
        } else if anchorages.isEmpty {
            return .default
        } else {
            let allPoints: [any Mappable] = anchorages + legs.flatMap {
                $0.route.points
            }
            return .fitting(points: allPoints)
        }
    }
    /// This is just routes
    var mmg: Double {
        legs.map { $0.mmg }.sum
    }
    /// If there were trips with actual miles sailed, it will use that, else same as ``mmg`` [the routes]
    var totalMiles: Double {
        legs.map { $0.totalMiles }.sum
    }
    func isDuplicate(_ i: Int) -> Bool {
        if i < 0 { return false }
        if legs.count - i < 1 { return false }
        return legs[i].mmg == 0
    }
    var isLocked: Bool {
        for leg in legs {
            if leg.trip != nil { return true }
        }
        return false
    }
}


// MARK: Editing
extension CruiseViewModel {
    func add(harbour: Harbour) {
        let day = anchorages.last?.id.adding(days: 1) ?? start.adding(days: -1)
        var new = Anchorage(id: day, harbour: harbour)
        new.winds = weather[new.zone, day]?.night ?? []
        anchorages.append(new)
        if anchorages.count > 1 {
            Task {
                do {
                    try await addLeg(from: anchorages[anchorages.count - 2], to: new)
                } catch {
                    logger.critical("Error adding harbour: \(error)")
                }
            }
        }
    }
    /// - Parameter i: A colour or leg index (-1 for zero on the anchorages)
    func canRemove(at i: Int) -> Bool {
        // not if only one
        if anchorages.count < 2 { return false }
        // same as for moving
        return canMove(i)
    }
    /// - Parameter i: A colour or leg index (-1 for zero on the anchorages)
    func remove(at i: Int) async throws {
        // if it's the last one, pretty straightforward
        if anchorages.count - i == 2 {
            anchorages.removeLast()
            legs.removeLast()
        }
        // if it's the first one, also pretty straightforward, but we'll need to update the days
        else if i == -1 {
            anchorages.removeFirst()
            legs.removeFirst()
            updateDays()
        }
        else {
            // remove the leg after it
            anchorages.remove(at: i+1)
            legs.remove(at: i+1)
            // route the leg before it to connect
            var leg = legs[i]
            let route = try await route(from: anchorages[i], to: anchorages[i+1])
            leg.route = route
            legs[i] = leg
            // update days
            updateDays()
        }
    }
    /// - Parameter i: A colour or leg index (-1 for zero on the anchorages)
    func canMove(_ i: Int) -> Bool {
        // if out of bounds, then no
        if i >= legs.count { return false }
        // if leg leading up to it has a trip, then no
        if i >= 0 {
            if legs[i].trip != nil { return false }
        }
        // if last then no outbound so we're good
        if legs.count - i == 1 { return true }
        // if outbound leg has a trip, then no
        if legs[i+1].trip != nil { return false }
        return true
    }
    /// - Parameter i: A colour or leg index (-1 for zero on the anchorages)
    func move(_ i: Int, to harbour: Harbour) {
        var old = anchorages[i+1]
        old.harbour = harbour
        old.notes = ""
        anchorages[i+1] = old
        Task {
            do {
                // revise inbound leg
                if (i >= 0) {
                    var oldLeg = legs[i]
                    let route = try await route(from: anchorages[i], to: old)
                    oldLeg.route = route
                    legs[i] = oldLeg
                }
                // revise outbound leg
                if legs.count - i > 1 {
                    var oldLeg = legs[i+1]
                    let route = try await route(from: old, to: anchorages[i+2])
                    oldLeg.route = route
                    legs[i+1] = oldLeg
                }
                updateDays()
            }
        }
    }
    /// - Parameter i: A colour or leg index (-1 for zero on the anchorages)
    func canInsert(after i: Int) -> Bool {
        // if it's out of bounds, no
        if i >= legs.count { return false }
        // if it's at the end, yes
        if legs.count - i == 1 { return true }
        // if the next leg has a trip, no
        if legs[i+1].trip != nil { return false }
        return true
    }
    /// - Parameter i: A colour or leg index (-1 for zero on the anchorages)
    func insert(harbour: Harbour, after i: Int) {
        if legs.count - i == 1 {
            add(harbour: harbour)
            return
        }
        // the day and weather are not important because I'm going to update days afterwards
        let new = Anchorage(id: .today, harbour: harbour)
        anchorages.insert(new, at: i+2)
        Task {
            do {
                // revise inbound leg
                var oldLeg = legs[i+1]
                var route = try await route(from: anchorages[i+1], to: new)
                oldLeg.route = route
                legs[i+1] = oldLeg
                // insert outbound leg
                route = try await self.route(from: new, to: anchorages[i+3])
                let newLeg = Leg(id: .today, route: route)
                legs.insert(newLeg, at: i+2)
                updateDays()
            } catch {
                logger.critical("Error inserting harbour: \(error)")
            }
        }
    }
    var canSetStart: Bool {
        for leg in legs {
            if leg.trip != nil { return false }
        }
        return true
    }
    var startDate: Date {
        get { start.start }
        set {
            self.start = newValue.day
            updateDays()
        }
    }
    private func updateDays() {
        let newValue = start.start
        for (i, var a) in anchorages.enumerated() {
            a.id = newValue.adding(days: i - 1).day
            a.winds = weather[a.zone, a.id]?.night ?? []
            anchorages[i] = a
        }
        for (i, var l) in legs.enumerated() {
            l.id = newValue.adding(days: i).day
            l.winds = weather[l.zone, l.id]?.day ?? []
            legs[i] = l
        }
    }
}


// MARK: Refreshing
extension CruiseViewModel {
    private func addLeg(from: Anchorage, to: Anchorage) async throws {
        let route = try await route(from: from, to: to)
        var leg = Leg(id: to.id, route: route)
        leg.winds = weather[leg.zone, leg.id]?.day ?? []
        legs.append(leg)
    }
    private func route(from: Anchorage, to: Anchorage) async throws -> RouteSnippet {
        if from.harbour.id == to.harbour.id {
            return .init([.init(from.harbour), .init(to.harbour)], generated: true)
        }
        guard let start = from.harbour.waypoint,
              let end = to.harbour.waypoint
        else { throw E.MissingWaypoint }
        return try await routeLoader.route(from: start.persistentModelID, to: end.persistentModelID) ?? .init([
            .init(from.harbour),
            .init(to.harbour)
        ], generated: true)
    }
    /// We'll get all the forecasts for all the mentioned zones and then put the winds into all of the anchorages and legs
    func refreshWeather() async throws {
        let zones = anchorages.map { $0.zone }.set
        for zone in zones {
            let snippets = try await forecasts.extendedMarineWeather(for: zone, start: start)
            try weather.update(zone: zone, snippets: snippets)
        }
        forecastFetched = .now
        populateWeather()
    }
    func populateWeather() {
        for (i, var a) in anchorages.enumerated() {
            a.winds = weather[a.zone, a.id]?.night ?? []
            anchorages[i] = a
        }
        for (i, var l) in legs.enumerated() {
            l.winds = l.trip?.marineForecast?.winds ?? weather[l.zone, l.id]?.day ?? []
            legs[i] = l
        }
    }
    // MARK: ERROR
    enum E: Error {
        case TripMismatch
        case MissingWaypoint
        case HarbourNotFound
        case AnchorageMismatch
        case Inelible
    }
}



// MARK: Anchorage
extension CruiseViewModel {
    struct Anchorage: Identifiable {
        var id: Day
        var harbour: Harbour
        /// Like if we want to comment on the tide needed for entrance
        var notes: String = ""
        /// Overnight winds
        var winds: [WindSnippet] = []
    }
    struct AnchorageSnippet: Codable {
        var harbourId: UUID
        var notes: String
        var winds: [WindSnippet]
        init(anchorage: Anchorage) {
            self.harbourId = anchorage.harbour.id
            self.notes = anchorage.notes
            self.winds = anchorage.winds
        }
    }
    var cachedAnchorages: [AnchorageSnippet] {
        anchorages.map {
            .init(anchorage: $0)
        }
    }
}
extension CruiseViewModel.Anchorage: Mappable {
    var coordinate: CLLocationCoordinate2D { harbour.coordinate }
    var label: String? { harbour.label }
    var formattedAddress: String? { nil }
    static func make(from point: any FoundationSalt.Mappable) -> CruiseViewModel.Anchorage? {
        point as? Self
    }
    var zone: MarineZone {
        .nearest(to: self) ?? .default
    }
}


// MARK: Leg
extension CruiseViewModel {
    struct Leg: Identifiable {
        var id: Day
        var route: RouteSnippet
        /// Only set if this was a leg that was already completed in the past
        var trip: Trip?
        /// The sailing winds during the day
        var winds: [WindSnippet] = []
    }
    struct LegSnippet: Codable {
        var route: RouteSnippet
        var trip_id: UUID?
        var winds: [WindSnippet]
        init(leg: Leg) {
            self.route = leg.route
            self.trip_id = leg.trip?.id
            self.winds = leg.winds
        }
    }
    var cachedLegs: [LegSnippet] {
        legs.map {
            .init(leg: $0)
        }
    }
}
extension [RouteSnippet] {
    var mapTiles: Set<MapTileBox> {
        self.flatMap {
            $0.mapTiles
        }.set
    }
}

extension CruiseViewModel.Leg {
    /// This is just the route
    var mmg: Double {
        route.distance
    }
    /// If there was a trip with actual miles sailed, it will use that, else same as ``mmg`` [the route]
    var totalMiles: Double {
        trip?.milesMadeGood ?? mmg
    }
    var bearing: Measurement<UnitAngle>? {
        route.bearing
    }
    /// So you can plot a dotted line from start to finish
    var endpoints: [WaypointSnippet] {
        [
            route.points.first,
            route.points.last
        ].compactMap { $0 }
    }
    func matches(start: (any Mappable), end: (any Mappable)) -> Bool {
        guard let s = route.points.first,
              let e = route.points.last
        else { return false }
        let threshold = Measurement<UnitLength>(value: 100, unit: .feet)
        return start.distance(to: s) < threshold && end.distance(to: e) < threshold
    }
    var zone: MarineZone {
        if let s = route.points.first {
            return .nearest(to: s) ?? .default
        }
        return .default
    }
    var middle: CLLocationCoordinate2D {
        let endpoints = endpoints
        let latitude = endpoints.map { $0.latitude }.avg
        let longitude = endpoints.map { $0.longitude }.avg
        return .init(latitude: latitude, longitude: longitude)
    }
}



// MARK: Persistence
extension Cruise {
    func viewModel(in context: ModelContext) throws -> CruiseViewModel {
        let anchorages: [CruiseViewModel.Anchorage] = try self.anchorages.enumerated().map { (i, a) in
            guard let harbour = Harbour.find(a.harbourId, in: context)
            else { throw CruiseViewModel.E.HarbourNotFound }
            return .init(id: self.start.adding(days: i - 1), harbour: harbour, notes: a.notes, winds: a.winds)
        }
        let legs: [CruiseViewModel.Leg] = self.legs.enumerated().map { (i, l) in
            .init(id: self.start.adding(days: i), route: l.route, trip: Trip.find(l.trip_id, in: context), winds: l.winds)
        }
        let new = CruiseViewModel(modelContainer: context.container, id: self.id, start: self.start, weather: self.weather, anchorages: anchorages, legs: legs)
        new.forecastFetched = self.forecastFetched
        new.colours = self.colours
        return new
    }
    func update(model: CruiseViewModel) {
        self.start = model.start
        self.weather = model.weather
        self.forecastFetched = model.forecastFetched
        self.colours = model.colours
        self.anchorages = model.cachedAnchorages
        self.legs = model.cachedLegs
        // AND ADD ANY NEW TRIPS?
    }
}
extension CruiseViewModel {
    /// You should add the trip relationships after inserting this into the context
    func newCruise() -> Cruise {
        Cruise(id: self.id, _anchorages: self.cachedAnchorages.encoded, _legs: self.cachedLegs.encoded, _start: self.start.start, forecastFetched: self.forecastFetched, _colours: self.colours.rawValue, _weather: self.weather.encoded)
    }
    func save(in context: ModelContext) throws {
        if let existing = Cruise.find(self.id, in: context) {
            existing.update(model: self)
        } else {
            let new = newCruise()
            context.insert(new)
            for trip in self.legs.compactMap({
                $0.trip
            }) {
                trip.cruise = new
                new.add(child: trip, to: \.trips)
            }
            Task {
                await TileDatabase.charts.preload(new.routes.mapTiles)
            }
        }
        try context.save()
    }
}
extension [Trip] {
    func makeCruise(with container: ModelContainer) async throws -> CruiseViewModel {
        guard self.isConsecutive
        else { throw CruiseViewModel.E.Inelible }
        // 1. Build the anchorages and legs
        var anchorages: [CruiseViewModel.Anchorage] = []
        var legs: [CruiseViewModel.Leg] = []
        for trip in self {
            guard let start = trip.startHarbour,
                  let end = trip.endHarbour
            else { throw CruiseViewModel.E.HarbourNotFound }
            let day = trip.date.day
            if anchorages.isEmpty {
                anchorages.append(.init(id: day.yesterday, harbour: start))
            }
            anchorages.append(.init(id: day, harbour: end))
            let route = trip.route ?? .init([
                .init(start),
                .init(end)
            ], generated: true)
            legs.append(.init(id: day, route: route, trip: trip, winds: trip.marineForecast?.winds ?? []))
        }
        // 2. Make the view model
        let new = CruiseViewModel(modelContainer: container, id: .init(), start: self[0].date.day, anchorages: anchorages, legs: legs)
        // 3. Refresh its weather
        try await new.refreshWeather()
        // 4. And return
        return new
    }
}
