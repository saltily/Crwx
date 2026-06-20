//
//  TripSchemaV1.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/11/24.
//

import Foundation
import SwiftData
import WxSalt
import FoundationSalt

enum TripSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Trip.self]
    }
    
    // MARK: Trip
    @Model
    final class Trip {
        
        // pre-departure
        var date: Date = Date.now.withoutTime
        var odometerStart: Int?
        var fuelStart: FuelSounding?
        var passengers: String = ""
        var dinghy: DinghyOption = DinghyOption.none
        var tidePredictions: [TidePredictionSnippet] = []
        var _localForecast: ForecastSnippet
//        {
//            get { nil }
//            set {}
//        }
        var _marineForecast: ForecastSnippet
//        {
//            get { nil }
//            set {}
//        }
        var buoyObservation: ObservationSnippet?
        
        // depart
        var departureTime: Date?
        var departureLocation: LocationSnippet?
        var departureWindSpeed: Double?
        var departureWindDirection: Double?
        var departureTide: TideSnapshotSnippet?
        var departureDepth: Double?
        var departureTidalCurrent: String = ""
        var departureObservation: ObservationSnippet?
        
        // voyage log
        var events: [VoyageEvent] = []
        
        // arrive
        var arrivalTime: Date?
        var arrivalLocation: LocationSnippet?
        var arrivalWindSpeed: Double?
        var arrivalWindDirection: Double?
        var arrivalTide: TideSnapshotSnippet?
        var arrivalDepth: Double?
        var arrivalTidalCurrent: String = ""
        var arrivalObservation: ObservationSnippet?

        // post-arrival
        var odometerEnd: Int?
        var fuelEnd: FuelSounding?
        var milesMadeGood: Double?
        var averageSpeed: Double?
        var maximumSpeed: Double?
        var comments: String = ""
        
        // possible future use
        var forceCompletion = false
        
        
        
        init(date: Date, odometerStart: Int? = nil, fuelStart: FuelSounding? = nil, passengers: String, dinghy: DinghyOption, tidePredictions: [TidePredictionSnippet], _localForecast: ForecastSnippet, _marineForecast: ForecastSnippet, buoyObservation: ObservationSnippet? = nil, departureTime: Date? = nil, departureLocation: LocationSnippet? = nil, departureWindSpeed: Double? = nil, departureWindDirection: Double? = nil, departureTide: TideSnapshotSnippet? = nil, departureDepth: Double? = nil, departureTidalCurrent: String, departureObservation: ObservationSnippet? = nil, events: [VoyageEvent], arrivalTime: Date? = nil, arrivalLocation: LocationSnippet? = nil, arrivalWindSpeed: Double? = nil, arrivalWindDirection: Double? = nil, arrivalTide: TideSnapshotSnippet? = nil, arrivalDepth: Double? = nil, arrivalTidalCurrent: String, arrivalObservation: ObservationSnippet? = nil, odometerEnd: Int? = nil, fuelEnd: FuelSounding? = nil, milesMadeGood: Double? = nil, averageSpeed: Double? = nil, maximumSpeed: Double? = nil, comments: String, forceCompletion: Bool = false) {
            self.date = date
            self.odometerStart = odometerStart
            self.fuelStart = fuelStart
            self.passengers = passengers
            self.dinghy = dinghy
            self.tidePredictions = tidePredictions
            self._localForecast = _localForecast
            self._marineForecast = _marineForecast
            self.buoyObservation = buoyObservation
            self.departureTime = departureTime
            self.departureLocation = departureLocation
            self.departureWindSpeed = departureWindSpeed
            self.departureWindDirection = departureWindDirection
            self.departureTide = departureTide
            self.departureDepth = departureDepth
            self.departureTidalCurrent = departureTidalCurrent
            self.departureObservation = departureObservation
            self.events = events
            self.arrivalTime = arrivalTime
            self.arrivalLocation = arrivalLocation
            self.arrivalWindSpeed = arrivalWindSpeed
            self.arrivalWindDirection = arrivalWindDirection
            self.arrivalTide = arrivalTide
            self.arrivalDepth = arrivalDepth
            self.arrivalTidalCurrent = arrivalTidalCurrent
            self.arrivalObservation = arrivalObservation
            self.odometerEnd = odometerEnd
            self.fuelEnd = fuelEnd
            self.milesMadeGood = milesMadeGood
            self.averageSpeed = averageSpeed
            self.maximumSpeed = maximumSpeed
            self.comments = comments
            self.forceCompletion = forceCompletion
        }
        
    }
    
    
    // MARK: Fuel Sounding
    struct FuelSounding: Codable, Equatable {
        var inches: Double? {
            didSet {
                if let inches {
                    self.gallons = inches / 22 * 50
                }
                else {
                    self.gallons = 0
                }
            }
        }
        var gallons: Double?
    }
    
    
    // MARK: DinghyOption
    enum DinghyOption: String, Codable, CaseIterable {
        case none, white, green
    }
    
    
    // MARK: Tides
    struct TideStationSnippet: Codable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
    }
    struct TidePredictionSnippet: Codable {
        var date: Date
        var height: Double
        var isHi: Bool
        var station: TideStationSnippet!
    }
    struct TideSnapshotSnippet: Codable {
        var date: Date
        var height: Double
        let movement: TideMovement
        let percentIn: Double
        let nextTide: TidePredictionSnippet!
        var station: TideStationSnippet!
    }
    
    
    // MARK: Forecasts
    struct LocationSnippet: Codable, Equatable {
        var name: String?
        let latitude: Double
        let longitude: Double
    }
    struct MarineZoneSnippet: Codable {
        let id: String
        let name: String
        let officialName: String
    }
    struct ForecastSnippet: Codable {
        var date: Date
        var _point: LocationSnippet
        var _zone: MarineZoneSnippet
        
        // conditions
        var symbolName: String = ""
        var highTemperature: Double?
        
        // wind
        var winds: [WindSnippet] = []
        
        // waves
        var lowWaveFeet: Int?
        var highWaveFeet: Int?
        
        // text
        var text: String = ""
        
        init(date: Date, point: LocationSnippet, zone: MarineZoneSnippet, symbolName: String = "", highTemperature: Double? = nil, winds: [WindSnippet], lowWaveFeet: Int? = nil, highWaveFeet: Int? = nil, text: String = "") {
            self.date = date
            self._point = point
            self._zone = zone
            self.symbolName = symbolName
            self.highTemperature = highTemperature
            self.winds = winds
            self.lowWaveFeet = lowWaveFeet
            self.highWaveFeet = highWaveFeet
            self.text = text
        }
        
    }
    struct WindSnippet: Codable, Equatable {
        var direction: Double?
        var gust: Double?
        var speed: Range<Double>
    }

    
    // MARK: Buoys
    struct MarineBuoySnippet: Codable {
        let id: String
        let name: String
        let subname: String
        let officialName: String
        let latitude: Double
        let longitude: Double
    }
    struct ObservationSnippet: Codable {
        let date: Date
        var buoy: MarineBuoySnippet!
        let airTemperature: Double?
        let waterTemperature: Double?
        var windDirection: Double?
        var windSpeed: Double?
        var gust: Double?
        var waveHeight: Double?
        var wavePeriod: TimeInterval?
        let averageWavePeriod: TimeInterval?
        let waveDirection: Double?
    }


    
    // MARK: Events
    struct VoyageEvent: Codable, Identifiable {
        var id: UUID = .init()
        var time: Date = .now
        var latitude: Double?
        var longitude: Double?
        var text: String = ""
    }

}
