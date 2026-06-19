//
//  ViewModel+Fetching.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/7/24.
//

import Foundation
import CoreLocation
import WeatherKit
import FoundationSalt
import SwiftData
import WxSalt

// MARK: Predeparture
extension PreDepartureViewModel {
    /// Optional called after departure
    mutating func refresh(loc: LocationSnippet?, buoy: MarineBuoySnippet?, station: TideStationSnippet?, context: ModelContext) async throws {
        guard let loc else { return }
        // if we have departed, make sure the date of the trip is on the same day and no later than departure
        if let departureTime {
            if self.date > departureTime ||
                self.date.withoutTime != departureTime.withoutTime
            {
                self.date = departureTime
            }
        }
        let baton = self.fetchPrevious(context)
        self.odometer = baton?.odometer
        self.fuel = baton?.fuel
        self.tidePredictions = try await fetchTide(at: loc.clLocation, preferred: station)
        self.buoyObservation = try await fetchObservation(near: loc.clLocation, preferred: buoy)
        self.marineForecast = try await fetchMarineForecast(for: loc.clLocation)
        let local = try await ForecastSnippet.fetchLocal(for: loc, at: self.date)
        self.localForecast = self.localForecast?.updating(with: local) ?? local
    }
    func fetchPrevious(_ context: ModelContext) -> TripBaton? {
        let refdate = self.trip?.date ?? self.date
        let predicate = #Predicate<Trip> {
            $0.date < refdate
        }
        if let previous = try? context.fetch(FetchDescriptor<Trip>(predicate: predicate, sortBy: [.init(\.date, order: .reverse)])).first
        {
            return previous.baton
        }
        return nil
    }
    var shouldFetchTide: Bool {
        tidePredictions.isEmpty
    }
    func fetchTide(at loc: CLLocation?, preferred: TideStationSnippet? = nil) async throws -> [TidePredictionSnippet] {
        guard let loc
        else { return [] }
        guard let station = preferred?.resolved ?? TideStation.all.nearest(to: loc)?.value
        else { throw "Could not find a tide station" }
        let service = TideWxService()
        return try await Retry.do(3) {
            let tides = try await service.weather(for: station, from: date.addingTimeInterval(-2.day), to: date.addingTimeInterval(2.day))
            let predictions = tides.predictions(for: date.day)
            guard !predictions.isEmpty
            else { throw "Could not find tide predictions for this day" }
            return predictions.snippets(station: station.snippet)
        }
    }
    var shouldFetchObservation: Bool {
        buoyObservation == nil && (-45.day...1.hour).contains(date.timeIntervalSinceNow)
    }
    func fetchObservation(near loc: CLLocation?, preferred: MarineBuoySnippet? = nil) async throws -> ObservationSnippet? {
        guard let loc
        else { return nil }
        guard let buoy = preferred?.resolved ?? MarineBuoy.offshore.nearest(to: loc)?.value
        else { throw "Could not find a weather buoy" }
        let service = MarineBuoyWxService()
        return try await Retry.do(3) {
            let wx = try await service.weather(for: buoy).filtering {
                $0.date <= date
            }
            guard let observation = wx.currentWeather
            else { return nil }
            return observation.snippet(buoy: buoy)
        }
    }
    var shouldFetchLocal: Bool {
        localForecast == nil && (-33.month...9.day).contains(date.timeIntervalSinceNow)
    }
    var shouldFetchMarine: Bool {
        marineForecast == nil && (-1.day...4.day).contains(date.timeIntervalSinceNow)
    }
    func fetchMarineForecast(for loc: CLLocation?) async throws -> ForecastSnippet? {
        guard let loc
        else { return nil }
        guard let zone = MarineZone.nearest(to: loc)
        else { throw "Could not find a marine zone" }
        let service = MarineZoneWxService()
        return try await Retry.do(3) {
            let wx = try await service.weather(for: zone)
            guard let forecast = wx.first(where: {
                HalfDay(date: $0.date).contains(date)
            }) ?? wx.first(where: {
                $0.date.withoutTime == date.withoutTime
            })
            else { return nil } // nothing for this date
            return .init(zone: zone, wx: forecast, date: wx.published ?? date)
        }
    }
}


// MARK: Underway
extension UnderwayViewModel {
    var shouldFetchTide: Bool {
        tide == nil
    }
    func fetchTide(at loc: CLLocation?) async throws -> TideSnapshotSnippet? {
        guard let loc,
              let time
        else { return nil }
        guard let station = self.suggestedTideStation?.resolved ?? TideStation.all.nearest(to: loc)?.value
        else { throw "Could not find a tide station" }
        let service = TideWxService()
        return try await Retry.do(3) {
            let tides = try await service.weather(for: station, from: time.addingTimeInterval(-2.day), to: time.addingTimeInterval(2.day))
            guard let height = tides.look(at: time)
            else { throw "Could not calculate height of tide for this time" }
            return height.snippet(station: station.snippet)
        }
    }
    var shouldFetchObservation: Bool {
        if let time {
            observation == nil && (-45.day...1.hour).contains(time.timeIntervalSinceNow)
        } else { observation == nil }
    }
    func fetchObservation(near loc: CLLocation?) async throws -> ObservationSnippet? {
        guard let loc,
              let time
        else { return nil }
        guard let buoy = self.suggestedBuoy?.resolved ?? MarineBuoy.offshore.nearest(to: loc)?.value
        else { throw "Could not find a weather buoy" }
        let service = MarineBuoyWxService()
        return try await Retry.do(3) {
            let wx = try await service.weather(for: buoy).filtering {
                $0.date <= time
            }
            guard let observation = wx.currentWeather
            else { return nil }
            return observation.snippet(buoy: buoy)
        }
    }
    func fetchCurrentWind(at loc: CLLocation?) async throws -> WindSnippet? {
        // note this will return nil if you're tapping to depart on a trip whose pre-departure was not set to today
        guard let loc,
              let time,
              time.timeIntervalSinceNow.magnitude < 20.minute
        else { return nil }
        let service = WeatherService()
        return try await Retry.do(3) {
            let wx = try await service.weather(for: loc)
            return .init(apple: wx.currentWeather.wind)
        }
    }
}


