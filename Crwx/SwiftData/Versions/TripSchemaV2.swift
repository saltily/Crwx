//
//  TripSchemaV2.swift
//  Mewx
//
//  Created by Matthew Goacher on 2/13/25.
//

import Foundation
import SwiftData
import WxSalt
import FoundationSalt

/// Add saved location profiles.
enum TripSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 1, 0)
    static var models: [any PersistentModel.Type] {
        [Trip.self, LocationProfile.self]
    }
    
    // MARK: LocationProfile
    @Model final class LocationProfile {
        var id: UUID = UUID()
        var name: String = ""
        var index: Int = 0
        var latitude: Double = 0
        var longitude: Double = 0
        var observations: String = WeatherStation.BarHarbor.rawValue
        // marine
        var marineLatitude: Double = 0
        var marineLongitude: Double = 0
        var _zone: Data?
        var _buoy: Data?
        // tides
        var _tides: Data?
        var _currents: Data?
        init(id: UUID, name: String, index: Int, latitude: Double, longitude: Double, observations: WeatherStation, marineLatitude: Double, marineLongitude: Double, _zone: Data? = nil, _buoy: Data? = nil, _tides: Data? = nil, _currents: Data? = nil) {
            self.id = id
            self.name = name
            self.index = index
            self.latitude = latitude
            self.longitude = longitude
            self.observations = observations.rawValue
            self.marineLatitude = marineLatitude
            self.marineLongitude = marineLongitude
            self._zone = _zone
            self._buoy = _buoy
            self._tides = _tides
            self._currents = _currents
        }
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
        var _marineForecast: ForecastSnippet
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
        
        
        
        init(date: Date = Date.now, odometerStart: Int? = nil, fuelStart: FuelSounding? = nil, passengers: String = "", dinghy: DinghyOption = DinghyOption.none, tidePredictions: [TidePredictionSnippet] = [], localForecast: ForecastSnippet, marineForecast: ForecastSnippet, buoyObservation: ObservationSnippet? = nil, departureTime: Date? = nil, departureLocation: LocationSnippet? = nil, departureWindSpeed: Double? = nil, departureWindDirection: Double? = nil, departureTide: TideSnapshotSnippet? = nil, departureDepth: Double? = nil, departureTidalCurrent: String = "", departureObservation: ObservationSnippet? = nil, events: [VoyageEvent] = [], arrivalTime: Date? = nil, arrivalLocation: LocationSnippet? = nil, arrivalWindSpeed: Double? = nil, arrivalWindDirection: Double? = nil, arrivalTide: TideSnapshotSnippet? = nil, arrivalDepth: Double? = nil, arrivalTidalCurrent: String = "", arrivalObservation: ObservationSnippet? = nil, odometerEnd: Int? = nil, fuelEnd: FuelSounding? = nil, milesMadeGood: Double? = nil, averageSpeed: Double? = nil, maximumSpeed: Double? = nil, comments: String = "", forceCompletion: Bool = false) {
            self.date = date
            self.odometerStart = odometerStart
            self.fuelStart = fuelStart
            self.passengers = passengers
            self.dinghy = dinghy
            self.tidePredictions = tidePredictions
            self._localForecast = localForecast
            self._marineForecast = marineForecast
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
    struct TideStationSnippet: Codable, Equatable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
    }
    struct TidePredictionSnippet: Codable, Equatable {
        var date: Date
        var height: Double
        var isHi: Bool
        var station: TideStationSnippet!
    }
    struct TideSnapshotSnippet: Codable, Equatable {
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
    struct MarineZoneSnippet: Codable, Equatable {
        let id: String
        let name: String
        let officialName: String
    }
    struct ForecastSnippet: Codable, Equatable {
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
    struct MarineBuoySnippet: Codable, Equatable {
        let id: String
        let name: String
        let subname: String
        let officialName: String
        let latitude: Double
        let longitude: Double
    }
    struct ObservationSnippet: Codable, Equatable {
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
    struct VoyageEvent: Codable, Identifiable, Equatable {
        var id: UUID = .init()
        var time: Date = .now
        var latitude: Double?
        var longitude: Double?
        var text: String = ""
    }

}
