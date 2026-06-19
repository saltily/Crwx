//
//  UnderwayViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import FoundationSalt
import SwiftData

struct UnderwayViewModel {
    
    // automated
    var time: Date?
    var location: LocationSnippet?
    var harbourId: UUID?
    var observation: ObservationSnippet?
    var tide: TideSnapshotSnippet?
    
    // semi-automated = review
    var tidalCurrent: String = ""
    var predictedTidalCurrent: String = ""
    
    // manual
    var depth: Double?
    var chartDepth: Double?
    let minTide: Double?
    var windSpeed: Double?
    var predictedWindSpeed: Double?
    var windDirection: Double?

    var trip: Trip?
    
    // suggested
    var suggestedBuoy: MarineBuoySnippet?
    var suggestedTideStation: TideStationSnippet?
}


// MARK: Extended
extension UnderwayViewModel {
    var isCompleted: Bool {
        guard !tidalCurrent.isEmpty else { return false }
        let mixed: [Any?] = [time, location, tide, depth, windSpeed, observation]
        guard mixed.compactMap({ $0 }).count == 6
        else { return false }
        return true
    }
    var isLoaded: Bool {
        if shouldFetchTide ||
            shouldFetchObservation
        { return false }
        let mixed: [Any?] = [time, location]
        guard mixed.compactMap({ $0 }).count == 2
        else { return false }
        return true
    }
    var percentComplete: Double {
        let totalPoints = 7.0
        var accumulatedPoints = 0.0
        if !tidalCurrent.isEmpty { accumulatedPoints += 1 }
        let mixed: [Any?] = [time, location, tide, depth, windSpeed, observation]
        accumulatedPoints += mixed.compactMap({
            $0
        }).count.double
        return accumulatedPoints / totalPoints
    }
    var isEmpty: Bool {
        let mixed: [Any?] = [time, tide, depth, windSpeed, windDirection, observation]
        guard mixed.compactMap({ $0 }).count == 0
        else { return false }
        guard tidalCurrent.isEmpty
        else { return false }
        return true
    }
    var windAngle: Measurement<UnitAngle>? {
        guard let direction = windDirection
        else { return nil }
        return .init(value: direction, unit: .degrees)
    }
    var compassDirection: CompassDirection {
        get {
            .init(cardinal: windAngle)
        }
        set {
            self.windDirection = newValue.direction?.converted(to: .degrees).value
        }
    }
    var ukc: Double? {
        guard let depth,
              let tide,
              let minTide
        else { return nil }
        return depth - tide.height + minTide - 6
    }
    /// Minimum to achieve 0 UKC
    var minDepth: Double? {
        guard let tide,
              let minTide
        else { return nil }
        // depth - tide + minTide - 6 = 0
        // depth = tide - minTide + 6
        return tide.height - minTide + 6
    }
    var estimatedDepth: Double? {
        guard let chartDepth,
              let tide
        else { return nil }
        return chartDepth + tide.height
    }
    func depthPlaceholder(_ landing: UnderwayButton.Landing) -> String? {
        switch landing {
        case .departure:
            guard let estimatedDepth
            else { return nil }
            return "est \(estimatedDepth.formatted(.number.precision(.fractionLength(0...1))))"
        case .arrival:
            guard let minDepth
            else { return nil }
            return "min \(minDepth.formatted(.number.precision(.fractionLength(0...1))))"
        }
    }
}


// MARK: Preview
extension UnderwayViewModel {
    static func preview(time: Date = .now, location: LocationSnippet = .random) -> UnderwayViewModel {
        .init(
            time: time,
            location: location,
            observation: .random(before: time),
            tide: .random,
            tidalCurrent: .randomTidalCurrent,
            depth: .random(in: 15...45),
            minTide: 0,
            windSpeed: .random(in: 0...20),
            windDirection: .random(in: 0...360),
            trip: nil
        )
    }
}
fileprivate extension String {
    static var randomTidalCurrent: String {
        [
            "slack before ebb",
            "slack before flood",
            "some flood",
            "start of ebb",
            "strong flood",
            "ebb"
        ].randomElement()!
    }
}


// MARK: Read from trip
extension Trip {
    var departure: UnderwayViewModel {
        .init(
            time: self.departureTime,
            location: self.departureLocation,
            harbourId: self.startHarbour?.id,
            observation: self.departureObservation,
            tide: self.departureTide,
            tidalCurrent: self.departureTidalCurrent,
            depth: self.departureDepth,
            minTide: self.tidePredictions.map { $0.height }.min(),
            windSpeed: self.departureWindSpeed,
            windDirection: self.departureWindDirection,
            trip: self,
            suggestedBuoy: self.buoyObservation?.buoy,
            suggestedTideStation: self.tidePredictions.first?.station
        )
    }
    var arrival: UnderwayViewModel {
        .init(
            time: self.arrivalTime,
            location: self.arrivalLocation,
            harbourId: self.endHarbour?.id,
            observation: self.arrivalObservation,
            tide: self.arrivalTide,
            tidalCurrent: self.arrivalTidalCurrent,
            depth: self.arrivalDepth,
            minTide: self.tidePredictions.map { $0.height }.min(),
            windSpeed: self.arrivalWindSpeed,
            windDirection: self.arrivalWindDirection,
            trip: self
        )
    }
}


// MARK: Write to Trip
extension Trip {
    func update(departure: UnderwayViewModel, context: ModelContext? = nil) {
        if let context {
            if let harbour = Harbour.find(departure.harbourId, in: context) {
                self.startHarbour = harbour
            } else if let location = departure.location {
                self.startHarbour = .at(location: location, in: context)
            }
        }

        self.departureTime = departure.time
        self.departureLocation = departure.location
        self.departureObservation = departure.observation
        self.departureWindSpeed = departure.windSpeed?.nilIfZero ?? departure.predictedWindSpeed
        self.departureWindDirection = departure.windDirection
        self.departureTide = departure.tide
        self.departureDepth = departure.depth
        self.departureTidalCurrent = departure.tidalCurrent.nilIfEmpty ?? departure.predictedTidalCurrent
    }
    func revertDeparture() {
        self.departureTime = nil
        // keeping the location
        self.departureObservation = nil
        self.departureWindSpeed = nil
        self.departureWindDirection = nil
        self.departureTide = nil
        self.departureDepth = nil
        self.departureTidalCurrent = ""
    }
    func update(arrival: UnderwayViewModel, context: ModelContext? = nil) {
        // establish harbour relationships
        if let context {
            if let harbour = Harbour.find(arrival.harbourId, in: context) {
                self.endHarbour = harbour
            } else if let location = arrival.location {
                self.endHarbour = .at(location: location, in: context)
            }
        }

        self.arrivalTime = arrival.time
        self.arrivalLocation = arrival.location
        self.arrivalObservation = arrival.observation
        self.arrivalWindSpeed = arrival.windSpeed?.nilIfZero ?? arrival.predictedWindSpeed
        self.arrivalWindDirection = arrival.windDirection
        self.arrivalTide = arrival.tide
        self.arrivalDepth = arrival.depth
        self.arrivalTidalCurrent = arrival.tidalCurrent.nilIfEmpty ?? arrival.predictedTidalCurrent
    }
    func revertArrival() {
        self.arrivalTime = nil
        let endHarbour = self.endHarbour
        remove(child: endHarbour, from: \.harbours)
        endHarbour?.remove(child: self, from: \.trips)
        self.arrivalLocation = nil
        self.arrivalObservation = nil
        self.arrivalWindSpeed = nil
        self.arrivalWindDirection = nil
        self.arrivalTide = nil
        self.arrivalDepth = nil
        self.arrivalTidalCurrent = ""
    }
}
