//
//  TripSchemaV4.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import Foundation
import SwiftData
import FoundationSalt
import WxSalt

/// Deprecating the old codable types in preparation for CloudKit and the future.
enum TripSchemaV4: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 2, 1)
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
    @Model final class Trip {
        
        // pre-departure
        var date: Date = Date.now.withoutTime
        var odometerStart: Int?
        var _fuelStartData: Data?
        var passengers: String = ""
        var _dinghyOption: String = "none"
        var _tidePredictionsData: Data?
        var _localForecastData: Data?
        var _marineForecastData: Data?
        var _buoyObservationData: Data?
        
        // depart
        var departureTime: Date?
        var _departureLocationData: Data?
        var departureWindSpeed: Double?
        var departureWindDirection: Double?
        var _departureTideData: Data?
        var departureDepth: Double?
        var departureTidalCurrent: String = ""
        var _departureObservationData: Data?
        
        // voyage log
        var _eventsData: Data?
        
        // arrive
        var arrivalTime: Date?
        var _arrivalLocationData: Data?
        var arrivalWindSpeed: Double?
        var arrivalWindDirection: Double?
        var _arrivalTideData: Data?
        var arrivalDepth: Double?
        var arrivalTidalCurrent: String = ""
        var _arrivalObservationData: Data?
        
        // post-arrival
        var odometerEnd: Int?
        var _fuelEndData: Data?
        var milesMadeGood: Double?
        var averageSpeed: Double?
        var maximumSpeed: Double?
        var comments: String = ""
        
        // possible future use
        var forceCompletion = false
        
        init() {}
        init(date: Date, odometerStart: Int? = nil, _fuelStartData: Data? = nil, passengers: String, _dinghyOption: String, _tidePredictionsData: Data? = nil, _localForecastData: Data? = nil, _marineForecastData: Data? = nil, _buoyObservationData: Data? = nil, departureTime: Date? = nil, _departureLocationData: Data? = nil, departureWindSpeed: Double? = nil, departureWindDirection: Double? = nil, _departureTideData: Data? = nil, departureDepth: Double? = nil, departureTidalCurrent: String, _departureObservationData: Data? = nil, _eventsData: Data? = nil, arrivalTime: Date? = nil, _arrivalLocationData: Data? = nil, arrivalWindSpeed: Double? = nil, arrivalWindDirection: Double? = nil, _arrivalTideData: Data? = nil, arrivalDepth: Double? = nil, arrivalTidalCurrent: String, _arrivalObservationData: Data? = nil, odometerEnd: Int? = nil, _fuelEndData: Data? = nil, milesMadeGood: Double? = nil, averageSpeed: Double? = nil, maximumSpeed: Double? = nil, comments: String, forceCompletion: Bool = false) {
            self.date = date
            self.odometerStart = odometerStart
            self._fuelStartData = _fuelStartData
            self.passengers = passengers
            self._dinghyOption = _dinghyOption
            self._tidePredictionsData = _tidePredictionsData
            self._localForecastData = _localForecastData
            self._marineForecastData = _marineForecastData
            self._buoyObservationData = _buoyObservationData
            self.departureTime = departureTime
            self._departureLocationData = _departureLocationData
            self.departureWindSpeed = departureWindSpeed
            self.departureWindDirection = departureWindDirection
            self._departureTideData = _departureTideData
            self.departureDepth = departureDepth
            self.departureTidalCurrent = departureTidalCurrent
            self._departureObservationData = _departureObservationData
            self._eventsData = _eventsData
            self.arrivalTime = arrivalTime
            self._arrivalLocationData = _arrivalLocationData
            self.arrivalWindSpeed = arrivalWindSpeed
            self.arrivalWindDirection = arrivalWindDirection
            self._arrivalTideData = _arrivalTideData
            self.arrivalDepth = arrivalDepth
            self.arrivalTidalCurrent = arrivalTidalCurrent
            self._arrivalObservationData = _arrivalObservationData
            self.odometerEnd = odometerEnd
            self._fuelEndData = _fuelEndData
            self.milesMadeGood = milesMadeGood
            self.averageSpeed = averageSpeed
            self.maximumSpeed = maximumSpeed
            self.comments = comments
            self.forceCompletion = forceCompletion
        }
        
    }
    
}
