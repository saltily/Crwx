//
//  SailingLookaheadViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/15/25.
//

import Foundation
import FoundationSalt
import SwiftData
import CoreLocation
import WxSalt

@Observable
final class SailingLookaheadViewModel: Identifiable {
    init(snapshot: SailingSnapshotViewModel, location: any Mappable, modelContainer: ModelContainer) {
        self.id = location.stamp
        self.location = location.coordinate
        let this_i = snapshot.route.index(nextReversedFrom: location)
        let my_i = snapshot.route.index(nextForwardFrom: snapshot.currentLocation)
        let points: [LocationSnippet]
        if my_i < this_i {
            points = [.init(snapshot.currentLocation)] + snapshot.route.points[my_i...this_i].map { .init($0) } + [.init(location)]
        } else if my_i == this_i {
            points = [
                .init(snapshot.currentLocation),
                .init(snapshot.route.points[my_i]),
                .init(location)
            ]
        } else {
            points = [
                .init(snapshot.currentLocation),
                .init(location)
            ]
        }
        let distance = points.totalDistance.converted(to: .nauticalMiles).value
        let ttg = (distance / (snapshot.sog ?? snapshot.smg ?? 2.3)).hour
        let eta = snapshot.currentTime.addingTimeInterval(ttg)
        self.points = points
        self.distance = distance
        self.ttg = ttg
        self.eta = eta
        self.tideStation = .nearest(to: location)
        self.marineZone = .nearest(to: location)
        self.engine = .init(modelContainer: modelContainer)
    }
    let id: String
    let location: CLLocationCoordinate2D
    let points: [LocationSnippet]
    let distance: Double
    let ttg: TimeInterval
    let eta: Date
    let engine: PotentialAnchorages.Engine
    let tideStation: TideStation?
    let marineZone: MarineZone?
    var tide: TideSnapshot?
    var winds: [WindSnippet]?
}


extension SailingLookaheadViewModel {
    func fetchWx() async throws {
        if let tideStation {
            self.tide = try await engine.forecasts.tide(for: tideStation, at: eta)
        }
        if let marineZone {
            self.winds = try await engine.forecasts.forecast(for: marineZone, during: eta.subtractingTimeInterval(30.minute)...eta.addingTimeInterval(30.minute)).flatMap { $0.winds }
        }
    }
}
