//
//  TripSchemaV8.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/20/25.
//

import Foundation
import SwiftData
import FoundationSalt
import WxSalt

/// Setting up relationships for track and route types, and cache analysis of tracks
enum TripSchemaV8: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 1, 2)
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
        var imported: Date = Date.now
        var endpointNames: String = ""
        var endpointIds: String = ""
        var endpointStamps: String = ""
        init(id: UUID, name: String, _waypoints: Data? = nil, length: Double, created: Date, imported: Date, endpointNames: String, endpointIds: String, endpointStamps: String) {
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
        var created: Date?
        var imported: Date = Date.now
        var stamp: String = ""
        init(id: UUID, source: String, latitude: Double, longitude: Double, name: String, _symbol: String? = nil, created: Date? = nil, imported: Date, stamp: String) {
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
        var imported: Date = Date.now
        var source: String = ""
        var stamp: String = ""
        init(id: UUID, name: String, date: Date? = nil, _points: Data? = nil, distance: Double, duration: TimeInterval? = nil, averageSpeed: Double? = nil, elevationGain: Double? = nil, imported: Date, source: String, stamp: String, trip: Trip? = nil) {
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
    static let migrateV7toV8: MigrationStage = .custom(fromVersion: TripSchemaV7.self, toVersion: TripSchemaV8.self, willMigrate: nil) { context in
        
        // Relate routes to waypoints
        let waypointMap: [UUID: TripSchemaV8.Waypoint] = try context.fetch(TripSchemaV8.Waypoint.self).reduce(into: [:]) { partialResult, wp in
            partialResult[wp.id] = wp
        }
        for route in try context.fetch(TripSchemaV8.Route.self) {
            let waypointIds: [UUID] = .init(decoding: route._waypoints) ?? []
            var related = route.waypointsUsed ?? []
            for id in waypointIds {
                guard let wp = waypointMap[id]
                else {
                    logger.critical("Couldn't find a waypoint when relating waypoints and routes")
                    throw MigrateError.MissingWaypoint
                }
                related.append(wp)
            }
            route.waypointsUsed = related
        }
        
        // Measure tracks
        for track in try context.fetch(TripSchemaV8.Track.self) {
            let segments: [[TrackPoint]] = .init(decoding: track._points) ?? []
            let points = segments.flatMap { $0 }
            let (distance, duration, speed, gain) = points.measure()
            track.distance = distance
            track.duration = duration
            track.averageSpeed = speed
            track.elevationGain = gain
        }
        
        try context.save()
    }
}

enum MigrateError: Error {
    case MissingWaypoint
}
