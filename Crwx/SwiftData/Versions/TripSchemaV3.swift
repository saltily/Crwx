//
//  TripSchemaV3.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import Foundation
import SwiftData
import FoundationSalt
import WxSalt

/// Incrementally remove codable types.
/// On the first pass I'm just going to move the same codable types out of the schema and confirm that the migration is happy with that.  Ok, it thinks they are equal.  So now I'm going to setup to migrate each to a custom data backing, with custom encoding.
enum TripSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 2, 0)
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
        var _fuelStartData: Data?
        var fuelStart: FuelSounding? // deprecate
        var passengers: String = ""
        var _dinghyOption: String = "none"
        var dinghy: DinghyOption = DinghyOption.none // deprecate
        var _tidePredictionsData: Data?
        var tidePredictions: [TidePredictionSnippet] = [] // deprecate
        var _localForecastData: Data?
        var _localForecast: ForecastSnippet // deprecate
        var _marineForecastData: Data?
        var _marineForecast: ForecastSnippet // deprecate
        var _buoyObservationData: Data?
        var buoyObservation: ObservationSnippet? // deprecate
        
        // depart
        var departureTime: Date?
        var _departureLocationData: Data?
        var departureLocation: LocationSnippet? // deprecate
        var departureWindSpeed: Double?
        var departureWindDirection: Double?
        var _departureTideData: Data?
        var departureTide: TideSnapshotSnippet? // deprecate
        var departureDepth: Double?
        var departureTidalCurrent: String = ""
        var _departureObservationData: Data?
        var departureObservation: ObservationSnippet? // deprecate
        
        // voyage log
        var _eventsData: Data?
        var events: [VoyageEvent] = []
        
        // arrive
        var arrivalTime: Date?
        var _arrivalLocationData: Data?
        var arrivalLocation: LocationSnippet? // deprecate
        var arrivalWindSpeed: Double?
        var arrivalWindDirection: Double?
        var _arrivalTideData: Data?
        var arrivalTide: TideSnapshotSnippet? // deprecate
        var arrivalDepth: Double?
        var arrivalTidalCurrent: String = ""
        var _arrivalObservationData: Data?
        var arrivalObservation: ObservationSnippet? // deprecate
        
        // post-arrival
        var odometerEnd: Int?
        var _fuelEndData: Data?
        var fuelEnd: FuelSounding? // deprecate
        var milesMadeGood: Double?
        var averageSpeed: Double?
        var maximumSpeed: Double?
        var comments: String = ""
        
        // possible future use
        var forceCompletion = false
        
        
        
        init(date: Date = Date.now, odometerStart: Int? = nil, fuelStart: FuelSounding? = nil, passengers: String = "", dinghy: DinghyOption = DinghyOption.none, tidePredictions: [TidePredictionSnippet] = [], localForecast: ForecastSnippet? = nil, marineForecast: ForecastSnippet? = nil, buoyObservation: ObservationSnippet? = nil, departureTime: Date? = nil, departureLocation: LocationSnippet? = nil, departureWindSpeed: Double? = nil, departureWindDirection: Double? = nil, departureTide: TideSnapshotSnippet? = nil, departureDepth: Double? = nil, departureTidalCurrent: String = "", departureObservation: ObservationSnippet? = nil, events: [VoyageEvent] = [], arrivalTime: Date? = nil, arrivalLocation: LocationSnippet? = nil, arrivalWindSpeed: Double? = nil, arrivalWindDirection: Double? = nil, arrivalTide: TideSnapshotSnippet? = nil, arrivalDepth: Double? = nil, arrivalTidalCurrent: String = "", arrivalObservation: ObservationSnippet? = nil, odometerEnd: Int? = nil, fuelEnd: FuelSounding? = nil, milesMadeGood: Double? = nil, averageSpeed: Double? = nil, maximumSpeed: Double? = nil, comments: String = "", forceCompletion: Bool = false) {
            self.date = date
            self.odometerStart = odometerStart
            self.fuelStart = fuelStart
            self.passengers = passengers
            self.dinghy = dinghy
            self.tidePredictions = tidePredictions
            self._localForecast = localForecast ?? .zero
            self._marineForecast = marineForecast ?? .zero
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
    
}


// MARK: Migration
extension TripMigrationPlan {
    static let migrateV2toV3: MigrationStage = .custom(fromVersion: TripSchemaV2.self, toVersion: TripSchemaV3.self, willMigrate: nil) { context in
        logger.info("Begin migration from V2 to V3.")
        for trip in try context.fetch(TripSchemaV3.Trip.self) {
            trip._fuelStartData = trip.fuelStart?.encoded
            trip._fuelEndData = trip.fuelEnd?.encoded
            trip._dinghyOption = trip.dinghy.rawValue
            trip._tidePredictionsData = trip.tidePredictions.encoded
            trip._localForecastData = trip._localForecast.encoded
            trip._marineForecastData = trip._marineForecast.encoded
            trip._buoyObservationData = trip.buoyObservation?.encoded
            trip._departureObservationData = trip.departureObservation?.encoded
            trip._arrivalObservationData = trip.arrivalObservation?.encoded
            trip._departureLocationData = trip.departureLocation?.encoded
            trip._arrivalLocationData = trip.arrivalLocation?.encoded
            trip._departureTideData = trip.departureTide?.encoded
            trip._arrivalTideData = trip.arrivalTide?.encoded
            trip._eventsData = trip.events.encoded
        }
        try context.save()
        logger.info("Migration complete.")
    }
}
