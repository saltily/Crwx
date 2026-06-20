//
//  TripSchemaV10.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/22/25.
//

import Foundation
import SwiftData
import FoundationSalt
import WxSalt
import os

/// Make imported date optional (custom routes and waypoints) and add a couple more harbour properties for capturing cruising guide info.
enum TripSchemaV10: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 2, 1)
    static var models: [any PersistentModel.Type] {
        [Trip.self, LocationProfile.self, Track.self, Waypoint.self, Route.self]
    }
    
    // MARK: Route
    @Model final class Route {
        var id: UUID = UUID()
        var name: String = ""
        var _waypoints: Data?
        var length: Double = 0
        var created: Date = Date.now
        var imported: Date?
        var reviewed: Date?
        var endpointNames: String = ""
        var endpointIds: String = ""
        var endpointStamps: String = ""
        init(id: UUID, name: String, _waypoints: Data? = nil, length: Double, created: Date, imported: Date? = nil, endpointNames: String, endpointIds: String, endpointStamps: String) {
            self.id = id
            self.name = name
            self._waypoints = _waypoints
            self.length = length
            self.created = created
            self.imported = imported
            self.endpointNames = endpointNames
            self.endpointIds = endpointIds
            self.endpointStamps = endpointStamps
        }
        @Relationship var waypointsUsed: [Waypoint]? = []
    }
    
    // MARK: Waypoint
    @Model final class Waypoint {
        var id: UUID = UUID()
        var source: String = ""
        var latitude: Double = 0
        var longitude: Double = 0
        var name: String = ""
        var _symbol: String?
        var _tint: Data?
        var created: Date?
        var imported: Date?
        var stamp: String = ""
        var isHub: Bool = false
        var notes: String = ""
        init(id: UUID, source: String, latitude: Double, longitude: Double, name: String, _symbol: String? = nil, created: Date? = nil, imported: Date? = nil, stamp: String) {
            self.id = id
            self.source = source
            self.latitude = latitude
            self.longitude = longitude
            self.name = name
            self._symbol = _symbol
            self.created = created
            self.imported = imported
            self.stamp = stamp
        }
        // wanted to do delete rule deny, but unsupported for CloudKit
        @Relationship(inverse: \Route.waypointsUsed) var routes: [Route]? = []
        var harbour: Harbour?
    }
    @Model final class Harbour {
        var id: UUID = UUID()
        var name: String = ""
        var latitude: Double = 0
        var longitude: Double = 0
        var _bottomType: String?
        var _chartDepth: Double?
        var _entranceDepth: Double?
        var _windExposure: Data?
        var _swellExposure: Data?
        var notes: String = ""
        var rating: Double?
        var _guideRating: Int?
        var _facilities: UInt16?
        var _protectionScore: Int?
        var _tideStation: Data?
        var _tidalCurrentStation: Data?
        var _marineZone: Data?
        var _marinePoint: Data?
        init(id: UUID, name: String, latitude: Double, longitude: Double, _bottomType: String? = nil, _chartDepth: Double? = nil, _entranceDepth: Double? = nil, _windExposure: Data? = nil, _swellExposure: Data? = nil, notes: String, rating: Double? = nil, _tideStation: Data? = nil, _tidalCurrentStation: Data? = nil, _marineZone: Data? = nil, _marinePoint: Data? = nil, waypoint: Waypoint? = nil) {
            self.id = id
            self.name = name
            self.latitude = latitude
            self.longitude = longitude
            self._bottomType = _bottomType
            self._chartDepth = _chartDepth
            self._entranceDepth = _entranceDepth
            self._windExposure = _windExposure
            self._swellExposure = _swellExposure
            self.notes = notes
            self.rating = rating
            self._tideStation = _tideStation
            self._tidalCurrentStation = _tidalCurrentStation
            self._marineZone = _marineZone
            self._marinePoint = _marinePoint
            self.waypoint = waypoint
        }
        @Relationship(inverse: \Waypoint.harbour) var waypoint: Waypoint?
    }
    
    // MARK: Track
    @Model final class Track {
        var id: UUID = UUID()
        var name: String = ""
        var date: Date?
        @Attribute(.externalStorage) var _points: Data?
        var distance: Double = 0 // nautical miles
        var duration: TimeInterval?
        var averageSpeed: Double? // knots
        var elevationGain: Double? // feet
        var imported: Date?
        var source: String = ""
        var stamp: String = ""
        init(id: UUID, name: String, date: Date? = nil, _points: Data? = nil, distance: Double, duration: TimeInterval? = nil, averageSpeed: Double? = nil, elevationGain: Double? = nil, imported: Date? = nil, source: String, stamp: String, trip: Trip? = nil) {
            self.id = id
            self.name = name
            self.date = date
            self._points = _points
            self.distance = distance
            self.duration = duration
            self.averageSpeed = averageSpeed
            self.elevationGain = elevationGain
            self.imported = imported
            self.source = source
            self.stamp = stamp
            self.trip = trip
        }
        @Relationship var trip: Trip?
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
        
        @Relationship(inverse: \Track.trip) var track: Track?
        
    }
    
}


// MARK: Migration
extension TripMigrationPlan {
    static let migrateV9toV10: MigrationStage = .custom(fromVersion: TripSchemaV9.self, toVersion: TripSchemaV10.self, willMigrate: nil) { context in
        context.migrateToV10()
    }
}

extension ModelContext {
    /// In this migration it will create harbour objects to match the waypoints that we think are harbours.
    func migrateToV10() {
        do {
            logger.info("Begin v10 migration")
            
            // clear out distant future import dates on routes, waypoints, and tracks - though we know we have no custom tracks
            let waypoints = try self.fetch(TripSchemaV10.Waypoint.self)
            for waypoint in waypoints {
                if waypoint.imported == .distantFuture {
                    waypoint.imported = nil
                }
            }
            let routes = try self.fetch(TripSchemaV10.Route.self)
            for route in routes {
                if route.imported == .distantFuture {
                    route.imported = nil
                }
            }

            try self.save()
            logger.info("v10 migration complete")
        } catch {
            logger.critical("Error trying to migrate vo V10: \(error)")
        }
    }
}
