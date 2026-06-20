//
//  Harbour+Potential.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/27/25.
//

import Foundation
import SwiftData
import FoundationSalt
import WxSalt

extension PotentialAnchorages.Engine {
    func potential(destination: HarbourViewModel, intent: VoyageIntent) async throws -> AnchoragePotential? {
        .init(viewModel: destination, intent: intent, context: modelContext)
    }
    enum E: Error {
        case BadId
    }
}

extension AnchoragePotential {
    init?(viewModel: HarbourViewModel, intent: VoyageIntent, context: ModelContext) {
        guard let start = Harbour.find(intent.start, in: context),
              let harbour = Harbour.find(viewModel.id, in: context)
        else { return nil }
        self.destination = viewModel.id
        self.name = harbour.name
        self.coordinate = harbour.coordinate
        self.facilities = harbour.facilities
        self.rating = harbour.rating ?? harbour.guideRating?.percentage
        self.bottom = harbour.bottomType
        self.mooringsAvailable = harbour.facilities.contains(.mooringsOrSlips)
        self.start = .init(start)
        let distance: Double
        if let route = viewModel.route,
           route.points.map({ $0.id }).ends.contains(intent.start)
        {
            self.route = route
            if let loc = intent.fromLocation {
                distance = route.dtg(from: loc)
            } else {
                distance = route.distance
            }
        } else {
            self.route = nil
            if let loc = intent.fromLocation {
                distance = loc.distance(to: viewModel).converted(to: .nauticalMiles).value
            } else {
                distance = start.distance(to: viewModel).converted(to: .nauticalMiles).value
            }
        }
        self.fromLocation = intent.fromLocation
        self.quadrantsFromStart = viewModel.quadrantsFromStart
        let hoursUnderway = distance / intent.estimatedSpeed
        self.eta = intent.estimatedDeparture.addingTimeInterval(hoursUnderway.hour)
        self.darkArrival = eta.isNighttime(at: viewModel)
        self.distance = distance
        self.duration = hoursUnderway.hour
        self.etd = intent.stayUntil
        if let d = harbour.chartDepth {
            minimumUKC = d - 6.0
        }
    }
    init(harbour: Harbour, start: LocationSnippet, route: RouteSnippet?, estimatedSpeed: Double, etd: Date, stayUntil: Date, quadrantsFromStart: Set<CompassQuadrant> = []) {
        self.destination = harbour.id
        self.name = harbour.name
        self.coordinate = harbour.coordinate
        self.facilities = harbour.facilities
        self.rating = harbour.rating ?? harbour.guideRating?.percentage
        self.bottom = harbour.bottomType
        self.mooringsAvailable = harbour.facilities.contains(.mooringsOrSlips)
        self.start = start
        self.route = route
        let distance = route?.distance ?? start.distance(to: harbour).converted(to: .nauticalMiles).value
        self.distance = distance
        self.quadrantsFromStart = quadrantsFromStart
        let hoursUnderway = distance / max(estimatedSpeed, 0.01)
        self.eta = etd.addingTimeInterval(hoursUnderway.hour)
        self.darkArrival = eta.isNighttime(at: harbour)
        self.duration = hoursUnderway.hour
        self.etd = stayUntil
        if let d = harbour.chartDepth {
            minimumUKC = d - 6.0
        }
    }
    init(harbour: Harbour, start: LocationSnippet, route: RouteSnippet?, eta: Date, duration: TimeInterval, distance: Double? = nil, stayUntil: Date, quadrantsFromStart: Set<CompassQuadrant> = []) {
        self.destination = harbour.id
        self.name = harbour.name
        self.coordinate = harbour.coordinate
        self.facilities = harbour.facilities
        self.rating = harbour.rating ?? harbour.guideRating?.percentage
        self.bottom = harbour.bottomType
        self.mooringsAvailable = harbour.facilities.contains(.mooringsOrSlips)
        self.start = start
        self.route = route
        let distance = distance ?? route?.distance ?? start.distance(to: harbour).converted(to: .nauticalMiles).value
        self.distance = distance
        self.quadrantsFromStart = quadrantsFromStart
        self.eta = eta
        self.darkArrival = eta.isNighttime(at: harbour)
        self.duration = duration
        self.etd = stayUntil
        if let d = harbour.chartDepth {
            minimumUKC = d - 6.0
        }
    }
}
extension PotentialAnchorages.Engine {
    func load(anchorage: AnchoragePotential) async throws -> AnchoragePotential {
        guard !anchorage.isLoaded else { return anchorage }
        guard let harbour = Harbour.find(anchorage.destination, in: modelContext)
        else { throw E.BadId }
        
        // tide at arrival
        try Task.checkCancellation()
        var anchorage = anchorage
        let snapshot = try await forecasts.tide(for: harbour.tideStation, at: anchorage.eta)
        anchorage.tideAtArrival = snapshot
        anchorage.tideStation = harbour.tideStation
        
        // ukc overnight
        let overnight: ClosedRange<Date>?
        if anchorage.eta <= anchorage.etd {
            overnight = anchorage.eta...anchorage.etd
        } else { overnight = nil }
        if let overnight,
           let harbourDepth = harbour.chartDepth
        {
            try Task.checkCancellation()
            let lowestTide = try await forecasts.lowestHeightOfTide(at: harbour.tideStation, during: overnight)
            anchorage.minimumUKC = harbourDepth + lowestTide - 6
        }
        if let overnight {
            anchorage.tides = try await forecasts.plots(for: harbour.tideStation, during: overnight)
        }

        // ukc at arrival
        if let arrivalDepth = harbour.entranceDepth ?? harbour.chartDepth {
            anchorage.ukcAtArrival = arrivalDepth + snapshot.height.converted(to: .feet).value - 6
        }
        
        if let overnight {
            try Task.checkCancellation()
            let forecast = try await forecasts.forecast(for: harbour.marineZone, during: overnight)
            anchorage.forecast = forecast

            // winds
            let winds = forecast.flatMap { $0.winds }
            var directions = await winds.directions
            anchorage.windExposure = harbour.windExposure.filtering(directions)
            for direction in directions {
                if let max = winds.max(direction) {
                    // gusting 15-20 is normal
                    if max > 20 {
                        anchorage.windExposure?.downgrade(direction)
                    }
                    // gusting 5 is totally calm
                    else if max <= 5 {
                        anchorage.windExposure?.safe(direction)
                    }
                    // gusting 10 is pretty good
                    else if max <= 10 {
                        anchorage.windExposure?.upgrade(direction)
                    }
                }
            }
            
            // waves
            let waves = forecast.flatMap { $0.waves }
            directions = await waves.directions
            anchorage.swellExposure = harbour.swellExposure.filtering(directions)
            for direction in directions {
                if let max = waves.max(direction) {
                    // 3-7 feet is normal
                    if max > 7 {
                        anchorage.swellExposure?.downgrade(direction)
                    }
                    // 1 foot is totally calm (if from the south)
                    else if max <= 1,
                            direction.isIn(.south, .southwest, .southeast)
                    {
                        anchorage.swellExposure?.safe(direction)
                    }
                    // 2 feet is pretty good
                    else if max <= 2 {
                        anchorage.swellExposure?.upgrade(direction)
                    }
                }
            }
            
        }
        
        // mark finished for next time
        try Task.checkCancellation()
        anchorage.isLoaded = true
        return anchorage
    }
}

struct WindLegend: ExposureLegend {
    func description(for level: CompassExposure.Level) -> String? {
        switch level {
        case .protected:
            "Protection from highest wind speeds in this direction."
        case .some:
            "Use caution with gusts 15-20. Ok in 10 knots of wind or less. Never above 20."
        case .exposed:
            "Use caution with 10 knotes or less. Ok in a calm. Never above 10."
        }
    }
}
struct WaveLegend: ExposureLegend {
    func description(for level: CompassExposure.Level) -> String? {
        switch level {
        case .protected:
            "Protection from all swells in this direction."
        case .some:
            "Use caution with 3-7 feet. Ok with 2 foot or less. Never above 7 feet."
        case .exposed:
            "Use caution with 2 foot or less. Ok when flat. Never above 2 feet."
        }
    }
}
