//
//  Trip.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import SwiftData
import FoundationSalt
import FoundationUI
import os
import WxSalt

typealias Trip = CurrentSchema.Trip


extension Trip {
    var fuelStart: FuelSounding? {
        get { .init(decoding: _fuelStartData) }
        set { _fuelStartData = newValue?.encoded }
    }
    var dinghy: DinghyOption {
        get { .init(rawValue: _dinghyOption) ?? .none }
        set { _dinghyOption = newValue.rawValue }
    }
    var tidePredictions: [TidePredictionSnippet] {
        get { .init(decoding: _tidePredictionsData) ?? [] }
        set { _tidePredictionsData = newValue.encoded }
    }
    var localForecast: ForecastSnippet? {
        get { .init(decoding: _localForecastData) }
        set { _localForecastData = newValue?.encoded }
    }
    var marineForecast: ForecastSnippet? {
        get { .init(decoding: _marineForecastData) }
        set { _marineForecastData = newValue?.encoded }
    }
    var buoyObservation: ObservationSnippet? {
        get { .init(decoding: _buoyObservationData) }
        set { _buoyObservationData = newValue?.encoded }
    }
    var departureLocation: LocationSnippet? {
        get { .init(decoding: _departureLocationData) }
        set { _departureLocationData = newValue?.encoded }
    }
    var timestampedDepartureLocation: LocationSnippet? {
        if var departureLocation,
           let departureTime
        {
            let time = departureTime.formatted(.dateTime.hour().minute())
            if let name = departureLocation.name {
                departureLocation.name = "\(time) - \(name)"
            } else {
                departureLocation.name = time
            }
            return departureLocation
        }
        return departureLocation
    }
    var departureTide: TideSnapshotSnippet? {
        get { .init(decoding: _departureTideData) }
        set { _departureTideData = newValue?.encoded }
    }
    var departureUKC: Double? {
        guard let departureDepth, let departureTide,
              let min = tidePredictions.map({ $0.height }).min()
        else { return nil }
        return departureDepth - departureTide.height + min - 6
    }
    var departureObservation: ObservationSnippet? {
        get { .init(decoding: _departureObservationData) }
        set { _departureObservationData = newValue?.encoded }
    }
    var events: [VoyageEvent] {
        get { .init(decoding: _eventsData) ?? [] }
        set { _eventsData = newValue.encoded }
    }
    var arrivalLocation: LocationSnippet? {
        get { .init(decoding: _arrivalLocationData) }
        set { _arrivalLocationData = newValue?.encoded }
    }
    var timestampedArrivalLocation: LocationSnippet? {
        if var arrivalLocation,
           let arrivalTime
        {
            let time = arrivalTime.formatted(.dateTime.hour().minute())
            if let name = arrivalLocation.name {
                arrivalLocation.name = "\(time) - \(name)"
            } else {
                arrivalLocation.name = time
            }
            return arrivalLocation
        }
        return arrivalLocation
    }
    var arrivalTide: TideSnapshotSnippet? {
        get { .init(decoding: _arrivalTideData) }
        set { _arrivalTideData = newValue?.encoded }
    }
    var arrivalUKC: Double? {
        guard let arrivalDepth, let arrivalTide,
              let min = tidePredictions.map({ $0.height }).min()
        else { return nil }
        return arrivalDepth - arrivalTide.height + min - 6
    }
    var arrivalObservation: ObservationSnippet? {
        get { .init(decoding: _arrivalObservationData) }
        set { _arrivalObservationData = newValue?.encoded }
    }
    var fuelEnd: FuelSounding? {
        get { .init(decoding: _fuelEndData) }
        set { _fuelEndData = newValue?.encoded }
    }
    var gallonsConsumed: Double? {
        guard let start = fuelStart?.gallons,
              let end =  fuelEnd?.gallons
        else { return nil }
        return start - end
    }
    var overallLeg: RouteLeg? {
        .init(start: departureLocation, end: arrivalLocation)
    }
    var cmg: Measurement<UnitAngle>? {
        guard let departureLocation,
              let arrivalLocation,
              departureLocation.distance(to: arrivalLocation).converted(to: .nauticalMiles).value > 0.5
        else { return nil }
        return arrivalLocation.bearing(from: departureLocation)
    }
    var percentFlooding: Double? {
        guard let start = departureTime,
              let end = arrivalTime,
              start < end
        else { return nil }
        return tidePredictions.percentFlooding(during: start..<end)
    }
    var hasNotes: Bool {
        !comments.isEmpty || !events.isEmpty
    }
    var route: RouteSnippet? {
        get { .init(decoding: _route) }
        set { _route = newValue?.encoded }
    }
    // Nautical miles from centre of harbour that can still be considered this harbour
    static let harbourThreshold = 1.0
    var startHarbour: Harbour? {
        get {
            guard let departureLocation else { return nil }
            return harbours?.first(where: {
                $0.distance(to: departureLocation) <= .init(value: Self.harbourThreshold, unit: .nauticalMiles)
            })
        }
        set {
            // should be close to the departure location
            guard let newValue,
                  newValue.distance(to: departureLocation).converted(to: .nauticalMiles).value < Self.harbourThreshold
            else { return }
            // only remove the old start if it is not the end
            let oldStart = startHarbour
            if oldStart != endHarbour {
                remove(child: oldStart, from: \.harbours)
                oldStart?.remove(child: self, from: \.trips)
            }
            // then add it
            add(child: newValue, to: \.harbours)
            newValue.add(child: self, to: \.trips)
        }
    }
    var endHarbour: Harbour? {
        get {
            guard let arrivalLocation else { return nil }
            return harbours?.first(where: {
                $0.distance(to: arrivalLocation) <= .init(value: Self.harbourThreshold, unit: .nauticalMiles)
            })
        }
        set {
            // should be close to the arrival location
            guard let newValue,
                  newValue.distance(to: arrivalLocation).converted(to: .nauticalMiles).value < Self.harbourThreshold
            else {
                logger.warning("The harbour is too far away? \(describing(newValue?.distance(to: self.arrivalLocation).converted(to: .nauticalMiles).value))")
                return
            }
            // only remove the old end if it is not the start
            let oldEnd = endHarbour
            if oldEnd != startHarbour {
                remove(child: oldEnd, from: \.harbours)
                oldEnd?.remove(child: self, from: \.trips)
            }
            // then add it
            add(child: newValue, to: \.harbours)
            newValue.add(child: self, to: \.trips)
        }
    }
    var chartDepthEnd: Double? {
        guard let arrivalDepth,
              let arrivalTide
        else {
            return endHarbour?.chartDepth
        }
        return arrivalDepth - arrivalTide.height
    }
    var overnightDepths: Range<Double>? {
        get { .init(decoding: _overnightDepths ) }
        set { _overnightDepths = newValue?.encoded }
    }
    var scope: String? {
        guard let fathoms,
              let overnightDepths
        else { return nil }
        let rodeLength = 6.0 * fathoms
        let minScope = (rodeLength / overnightDepths.upperBound).formatted(.number.precision(.fractionLength(0...1)))
        let maxScope = (rodeLength / overnightDepths.lowerBound).formatted(.number.precision(.fractionLength(0...1)))
        return "\(maxScope) | \(minScope) :1"
    }
    var depthRange: String? {
        guard let overnightDepths
        else { return nil }
        let min = overnightDepths.lowerBound.rounded.formatted(.number)
        let max = overnightDepths.upperBound.rounded.formatted(.number)
        return "\(min)-\(max) ft"
    }
    var maximumSwing: Double? {
        guard let minimumDepth = overnightDepths?.lowerBound,
              let fathoms
        else { return nil }
        // x^2 + depth^2 = rode^2
        // x^2 = rode^2 - depth^2
        let rode = 6.0 * fathoms
        guard rode > minimumDepth
        else { return nil }
        let distance = (pow(rode, 2) - pow(minimumDepth, 2)).squareRoot()
        return distance + 35.0
    }
}


// MARK: Fetching
extension Predicate {
    static func tripsBy(year: Int) -> Predicate<Trip> {
        let firstOfYear = try! Date(month: 1, day: 1, year: year)
        let firstOfNextYear = try! Date(month: 1, day: 1, year: year+1)
        return #Predicate {
            $0.date >= firstOfYear &&
            $0.date < firstOfNextYear
        }
    }
}
extension [SortDescriptor<Trip>] {
    static func defaultSortOrder(_ year: Int) -> Self {
        [
            .init(\.date, order: year == Date.now.year ? .reverse : .forward)
        ]
    }
}
extension FetchDescriptor<Trip> {
    static func lastTrip() -> FetchDescriptor<Trip> {
        var d = FetchDescriptor(sortBy: [.init(\.date, order: .reverse)])
        d.fetchLimit = 1
        return d
    }
}
extension Trip {
    static func find(_ id: UUID?, in context: ModelContext) -> Trip? {
        guard let id else { return nil }
        return try? context.fetchOne(#Predicate {
            $0.id == id
        })
    }
    static func lastTrip(in context: ModelContext) -> Trip? {
        try? context.fetchOne(.lastTrip())
    }
    func fetchPrevious(_ context: ModelContext) -> Trip? {
        let refdate = self.date
        let predicate = #Predicate<Trip> {
            $0.date < refdate
        }
        if let previous = try? context.fetch(FetchDescriptor<Trip>(predicate: predicate, sortBy: [.init(\.date, order: .reverse)])).first
        {
            return previous
        }
        return nil
    }
}


// MARK: Link to Track
extension Trip: Linkable {
    func hasLink<T>(_ type: T.Type) -> Bool where T : Linkable {
        guard type == Track.self else { return false }
        return track != nil
    }
    
    func linkTo<T>(_ items: [T]) -> Bool where T : Linkable {
        guard let track = items.compactMap({
            $0 as? Track
        }).first else { return false }
        self.track = track
        track.trip = self
        track.date = self.date
        return true
    }
    
    func linkedIds<T>(_ type: T.Type) -> [T.ID] where T : Linkable {
        guard type == Track.self,
              let track
        else { return [] }
        return [track.id] as! [T.ID]
    }
    
    func unlink<T>(_ type: T.Type) where T : Linkable {
        guard type == Track.self else { return }
        track = nil
    }
}


extension Trip {
    func updateOvernightDepths() async throws {
        guard let chartDepthEnd,
              let arrivalTime
        else {
            overnightDepths = nil
            return
        }
        // let's get some tide predictions
        var tideStation = endHarbour?.tideStation
        if tideStation == nil,
           let location = arrivalLocation
        {
            tideStation = .nearest(to: location)
        }
        let lowestTide: Double?
        let highestTide: Double?
        let tomorrowDeparture = max(arrivalTime.addingTimeInterval(8.hour), arrivalTime.withoutTime.tomorrow.addingTimeInterval(10.hour))
        let overnight = arrivalTime...tomorrowDeparture
        if let tideStation {
            let forecasts = CoastalForecasts()
            lowestTide = try await forecasts.lowestHeightOfTide(at: tideStation, during: overnight)
            highestTide = try await forecasts.highestHeightOfTide(at: tideStation, during: overnight)
        } else {
            let predictions = tidePredictions
            let heights = predictions.map {
                $0.height
            }.sorted()
            lowestTide = heights.first
            highestTide = heights.last
        }
        guard let lowestTide,
              let highestTide
        else {
            overnightDepths = nil
            return
        }
        let minimumDepth = chartDepthEnd + lowestTide
        let maximumDepth = chartDepthEnd + highestTide
        guard minimumDepth < maximumDepth
        else { throw CoastalForecasts.E.OutOfBounds }
        overnightDepths = minimumDepth..<maximumDepth
    }
}

extension Trip {
    /// Called just before deleting the trip, so stray id isn't left dangling
    func removeFromCruise() {
        if let cruise {
            for (i, var leg) in cruise.legs.enumerated() {
                if leg.trip_id == id {
                    leg.trip_id = nil
                    cruise.legs[i] = leg
                }
            }
            cruise.remove(child: self, from: \.trips)
            self.cruise = nil
        }
    }
}



// MARK: Web Sharing
extension Trip: Encodable {
    enum CodingKeys: CodingKey {
        case id, uuid
        case date, odometerStart, fuelStart, passengers, dinghy, tidePredictions, localForecast, marineForecast, buoyObservation
        case departureTime, departureLocation, departureWindSpeed, departureWindDirection, departureTide, departureDepth, departureTidalCurrent, departureObservation
        case events
        case arrivalTime, arrivalLocation, arrivalWindSpeed, arrivalWindDirection, arrivalTide, arrivalDepth, arrivalTidalCurrent, arrivalObservation, overnightDepths
        case odometerEnd, fathoms, fuelEnd, milesMadeGood, averageSpeed, maximumSpeed, comments
        case route
        case track, startHarbour, endHarbour, cruise_id
        case departureUKC, arrivalUKC, gallonsConsumed, overallLeg, cmg, percentFlooding, chartDepthEnd, scope, depthRange, maximumSwing
    }
    /// This is specifically to send json to website for sharing
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .uuid)
        try container.encodeIfPresent(webId, forKey: .id)
        try container.encode(date.reader().mysql_datetime, forKey: .date)
        try container.encodeIfPresent(odometerStart, forKey: .odometerStart)
        try container.encodeIfPresent(fuelStart, forKey: .fuelStart)
        try container.encode(passengers, forKey: .passengers)
        try container.encode(dinghy.rawValue, forKey: .dinghy)
        try container.encodeIfPresent(tidePredictions, forKey: .tidePredictions)
        try container.encodeIfPresent(localForecast, forKey: .localForecast)
        try container.encodeIfPresent(marineForecast, forKey: .marineForecast)
        try container.encodeIfPresent(buoyObservation, forKey: .buoyObservation)
        try container.encodeIfPresent(departureTime?.reader().mysql_datetime, forKey: .departureTime)
        try container.encodeIfPresent(departureLocation, forKey: .departureLocation)
        try container.encodeIfPresent(departureWindSpeed, forKey: .departureWindSpeed)
        try container.encodeIfPresent(departureWindDirection, forKey: .departureWindDirection)
        try container.encodeIfPresent(departureTide, forKey: .departureTide)
        try container.encodeIfPresent(departureDepth, forKey: .departureDepth)
        try container.encode(departureTidalCurrent, forKey: .departureTidalCurrent)
        try container.encodeIfPresent(departureObservation, forKey: .departureObservation)
        try container.encode(events, forKey: .events)
        try container.encodeIfPresent(arrivalTime?.reader().mysql_datetime, forKey: .arrivalTime)
        try container.encodeIfPresent(arrivalLocation, forKey: .arrivalLocation)
        try container.encodeIfPresent(arrivalWindSpeed, forKey: .arrivalWindSpeed)
        try container.encodeIfPresent(arrivalWindDirection, forKey: .arrivalWindDirection)
        try container.encodeIfPresent(arrivalTide, forKey: .arrivalTide)
        try container.encodeIfPresent(arrivalDepth, forKey: .arrivalDepth)
        try container.encode(arrivalTidalCurrent, forKey: .arrivalTidalCurrent)
        try container.encodeIfPresent(arrivalObservation, forKey: .arrivalObservation)
        try container.encodeIfPresent(overnightDepths, forKey: .overnightDepths)
        try container.encodeIfPresent(odometerEnd, forKey: .odometerEnd)
        try container.encodeIfPresent(fathoms, forKey: .fathoms)
        try container.encodeIfPresent(fuelEnd, forKey: .fuelEnd)
        try container.encodeIfPresent(milesMadeGood, forKey: .milesMadeGood)
        try container.encodeIfPresent(averageSpeed, forKey: .averageSpeed)
        try container.encodeIfPresent(maximumSpeed, forKey: .maximumSpeed)
        try container.encode(comments, forKey: .comments)
        try container.encodeIfPresent(route, forKey: .route)
        try container.encodeIfPresent(track?.points.thin(by: 10), forKey: .track)
        try container.encodeIfPresent(startHarbour, forKey: .startHarbour)
        try container.encodeIfPresent(endHarbour, forKey: .endHarbour)
        try container.encodeIfPresent(cruise?.webId, forKey: .cruise_id)
        try container.encodeIfPresent(departureUKC, forKey: .departureUKC)
        try container.encodeIfPresent(arrivalUKC, forKey: .arrivalUKC)
        try container.encodeIfPresent(gallonsConsumed, forKey: .gallonsConsumed)
        try container.encodeIfPresent(overallLeg, forKey: .overallLeg)
        try container.encodeIfPresent(cmg?.converted(to: .degrees).value.rounded, forKey: .cmg)
        try container.encodeIfPresent(percentFlooding, forKey: .percentFlooding)
        try container.encodeIfPresent(chartDepthEnd, forKey: .chartDepthEnd)
        try container.encodeIfPresent(scope, forKey: .scope)
        try container.encodeIfPresent(depthRange, forKey: .depthRange)
        try container.encodeIfPresent(maximumSwing, forKey: .maximumSwing)
    }
}
extension Trip: WebShareable {
    func share(_ context: ModelContext) async throws -> URL {
        if let id = self.webId {
            let url = URL(string: "https://www.saltily.com/blouse/update-trip")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = self.json
            let (data, _) = try await URLSession.shared.data(for: request)
            if let string = String(data: data, encoding: .utf8) {
                logger.trace("\(string)")
            }
            guard let result = try WebShareResult(json: data)
            else {
                throw WebShareResult.E.InvalidResponse
            }
            if let error = result.error {
                throw WebShareResult.E.Online(error)
            }
            if let success = result.success {
                logger.info("\(success)")
            }
            return URL(string: "https://www.saltily.com/blouse/trip?id=\(id)")!
        }
        else {
            let url = URL(string: "https://www.saltily.com/blouse/upload-trip")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = self.json
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let result = try WebShareResult(json: data)
            else {
                if let string = String(data: data, encoding: .utf8) {
                    logger.trace("\(string)")
                }
                throw WebShareResult.E.InvalidResponse
            }
            if let error = result.error {
                throw WebShareResult.E.Online(error)
            }
            guard let id = result.id
            else { throw WebShareResult.E.InvalidResponse }
            self.webId = id
            if let startHarbour_id = result.startHarbour_id {
                self.startHarbour?.webId = startHarbour_id
            }
            if let endHarbour_id = result.endHarbour_id {
                self.endHarbour?.webId = endHarbour_id
            }
            try context.save()
            return URL(string: "https://www.saltily.com/blouse/trip?id=\(id)")!
        }
    }
}
