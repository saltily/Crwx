//
//  TripViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import Foundation
import SwiftData
import FoundationSalt

struct TripViewModel: Backupable {
    var persistentId: PersistentIdentifier?
    
    // pre-departure
    var date: Date = Date.now.withoutTime
    var odometerStart: Int?
    var fuelStart: FuelSounding?
    var passengers: String = ""
    var dinghy: DinghyOption = DinghyOption.none
    var tidePredictions: [TidePredictionSnippet] = []
    var localForecast: ForecastSnippet?
    var marineForecast: ForecastSnippet?
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
}

extension TripViewModel {
    init(persistentModel: Trip) throws {
        persistentId = persistentModel.persistentModelID

        date = persistentModel.date
        odometerStart = persistentModel.odometerStart
        fuelStart = persistentModel.fuelStart
        passengers = persistentModel.passengers
        dinghy = persistentModel.dinghy
        tidePredictions = persistentModel.tidePredictions
        localForecast = persistentModel.localForecast
        marineForecast = persistentModel.marineForecast
        buoyObservation = persistentModel.buoyObservation

        departureTime = persistentModel.departureTime
        departureLocation = persistentModel.departureLocation
        departureWindSpeed = persistentModel.departureWindSpeed
        departureWindDirection = persistentModel.departureWindDirection
        departureTide = persistentModel.departureTide
        departureDepth = persistentModel.departureDepth
        departureTidalCurrent = persistentModel.departureTidalCurrent
        departureObservation = persistentModel.departureObservation

        events = persistentModel.events
        
        arrivalTime = persistentModel.arrivalTime
        arrivalLocation = persistentModel.arrivalLocation
        arrivalWindSpeed = persistentModel.arrivalWindSpeed
        arrivalWindDirection = persistentModel.arrivalWindDirection
        arrivalTide = persistentModel.arrivalTide
        arrivalDepth = persistentModel.arrivalDepth
        arrivalTidalCurrent = persistentModel.arrivalTidalCurrent
        arrivalObservation = persistentModel.arrivalObservation
        
        odometerEnd = persistentModel.odometerEnd
        fuelEnd = persistentModel.fuelEnd
        milesMadeGood = persistentModel.milesMadeGood
        averageSpeed = persistentModel.averageSpeed
        maximumSpeed = persistentModel.maximumSpeed
        comments = persistentModel.comments

        forceCompletion = persistentModel.forceCompletion
    }
    func insert(into context: ModelContext) throws {
        
    }
}
