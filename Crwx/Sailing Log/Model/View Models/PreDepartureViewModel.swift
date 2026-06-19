//
//  PreDepartureViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import FoundationSalt

struct PreDepartureViewModel {
    
    // automated
    var date: Date = .now.withoutTime
    var tidePredictions: [TidePredictionSnippet] = []
    var localForecast: ForecastSnippet?
    var marineForecast: ForecastSnippet?
    var buoyObservation: ObservationSnippet?
    
    // semi-automated = review
    // name of location
    var odometer: Int?
    var fuel: FuelSounding?

    // manual
    var passengers: String = ""
    var dinghy: DinghyOption = .none
    
    // informational
    var departureTime: Date?
    var departureLocation: LocationSnippet?
    var anchorage: Harbour?
    var anchorageHighlights: String
    var anchorageNotes: String
    
    // for saving
    var trip: Trip?

}


// MARK: Extended
extension PreDepartureViewModel: Identifiable {
    var id: Date { date }
    var isCompleted: Bool {
        guard !tidePredictions.isEmpty else { return false }
        let mixed: [Any?] = [localForecast, marineForecast, buoyObservation, odometer, fuel]
        guard mixed.compactMap({
            $0
        }).count == 5
        else { return false }
        return true
    }
    var isLoaded: Bool {
        if shouldFetchTide ||
            shouldFetchObservation ||
            shouldFetchLocal ||
            shouldFetchMarine
        { return false }
        return true
    }
    var percentComplete: Double {
        let totalPoints = 6.0
        var accumulatedPoints = 0.0
        if !tidePredictions.isEmpty { accumulatedPoints += 1 }
        let mixed: [Any?] = [localForecast, marineForecast, buoyObservation, odometer, fuel]
        accumulatedPoints += mixed.compactMap({
            $0
        }).count.double
        return accumulatedPoints / totalPoints
    }
    var isEmpty: Bool {
        let mixed: [Any?] = [localForecast, marineForecast, buoyObservation]
        guard mixed.compactMap({
            $0
        }).count == 0
        else { return false }
        guard tidePredictions.isEmpty,
              passengers.isEmpty,
              dinghy == .none
        else { return false }
        return true
    }
}


// MARK: Preview
extension PreDepartureViewModel {
    static func preview(date: Date = .now, location: LocationSnippet = .random, odometer: Int = .random(in: 300..<400), fuel: FuelSounding = .random) -> PreDepartureViewModel {
        .init(
            date: date.withoutTime,
            tidePredictions: .random(on: date),
            localForecast: .random(before: date, point: location),
            marineForecast: .random(true, before: date, point: nil),
            buoyObservation: .random(before: date),
            odometer: odometer,
            fuel: fuel,
            passengers: .randomPassengers,
            dinghy: .random,
            departureTime: nil,
            anchorage: nil,
            anchorageHighlights: "",
            anchorageNotes: "",
            trip: nil
        )
    }
}
extension String {
    static var randomPassengers: String {
        [
            "",
            "Tom, Sharon, Josh",
            "Erin",
            "",
            "Nathan, Julie, Rowan",
            "Tom, Chris",
            "Mom",
        ].randomElement()!
    }
}


// MARK: Read from trip
extension Trip {
    var predeparture: PreDepartureViewModel {
        .init(
            date: self.date,
            tidePredictions: self.tidePredictions,
            localForecast: self.localForecast,
            marineForecast: self.marineForecast,
            buoyObservation: self.buoyObservation,
            odometer: self.odometerStart,
            fuel: self.fuelStart,
            passengers: self.passengers,
            dinghy: self.dinghy,
            departureTime: self.departureTime,
            departureLocation: self.departureLocation,
            anchorage: self.startHarbour,
            anchorageHighlights: self.startHarbour?.protectionHighlights ?? "",
            anchorageNotes: self.startHarbour?.notes ?? "",
            trip: self
        )
    }
}


// MARK: Write to trip
extension Trip {
    func update(predeparture: PreDepartureViewModel) {
        self.date = predeparture.date
        self.tidePredictions = predeparture.tidePredictions
        // weather is never taken in the future
        // if the weather is more than an hour after departure, then don't allow it
        if let latestWeatherDate = departureTime?.addingTimeInterval(1.hour) {
            // we have departed, so we don't want weather too far into the future
            if let localForecast = predeparture.localForecast,
               localForecast.date < latestWeatherDate 
            {
                self.localForecast = localForecast
            }
            if let marineForecast = predeparture.marineForecast,
               marineForecast.date < latestWeatherDate
            {
                self.marineForecast = marineForecast
            }
            if let buoyObservation = predeparture.buoyObservation,
               buoyObservation.date < latestWeatherDate
            {
                self.buoyObservation = buoyObservation
            }
        }
        else {
            self.localForecast = predeparture.localForecast
            self.marineForecast = predeparture.marineForecast
            self.buoyObservation = predeparture.buoyObservation
        }
        self.odometerStart = predeparture.odometer
        self.fuelStart = predeparture.fuel
        self.passengers = predeparture.passengers
        self.dinghy = predeparture.dinghy
        if self.departureLocation == nil {
            self.departureLocation = predeparture.localForecast?.point
        }
        predeparture.anchorage?.protectionHighlights = predeparture.anchorageHighlights
        predeparture.anchorage?.notes = predeparture.anchorageNotes
    }
    func revertPredeparture() {
        self.tidePredictions = []
        self.localForecast = nil
        self.marineForecast = nil
        self.buoyObservation = nil
        self.passengers = ""
        self.dinghy = .none
        self.departureLocation = nil
    }
}
