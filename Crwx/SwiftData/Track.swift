//
//  Track.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import Foundation
import SwiftData
import FoundationSalt
import FoundationUI

typealias Track = CurrentSchema.Track

extension Track {
    var segments: [[TrackPoint]] {
        get { .init(decoding: _points) ?? [] }
        set { _points = newValue.encoded }
    }
    var points: [TrackPoint] {
        get { segments.allVisible }
//        set { segments = [newValue] }
    }
    var start: LocationSnippet? {
        guard let first = points.first else { return nil }
        let label: String
        if let time = first.time {
            label = "\(time.formatted(.dateTime.hour().minute())) - Start"
        } else {
            label = "Start"
        }
        return .init(name: label, latitude: first.latitude, longitude: first.longitude)
    }
    var end: LocationSnippet? {
        guard let last = points.last else { return nil }
        let label: String
        if let time = last.time {
            label = "\(time.formatted(.dateTime.hour().minute())) - End"
        } else {
            label = "End"
        }
        return .init(name: label, latitude: last.latitude, longitude: last.longitude)
    }
    var cmg: Measurement<UnitAngle>? {
        guard let start,
              let end,
              start.distance(to: end).converted(to: .nauticalMiles).value > 0.5
        else { return nil }
        return end.bearing(from: start)
    }
    var sourceImage: String {
        if source.contains("echoMAP") {
            return "sailboat"
        } else if source.contains("Gaia") {
            return "figure.hiking"
        } else {
            return "map"
        }
    }
    /// In nautical miles
    var totalLength: Double {
        points.totalDistance.converted(to: .nauticalMiles).value
    }
    func remeasure() {
        let (distance, duration, speed, gain) = points.measure()
        self.distance = distance
        self.duration = duration
        self.averageSpeed = speed
        self.elevationGain = gain
    }
}


// MARK: Fetching
extension Predicate {
    static func tracksBy(year: Int) -> Predicate<Track> {
        let firstOfYear = try! Date(month: 1, day: 1, year: year)
        let firstOfNextYear = try! Date(month: 1, day: 1, year: year+1)
        return #Predicate {
            $0.date >= firstOfYear &&
            $0.date < firstOfNextYear
        }
    }
}
extension [SortDescriptor<Track>] {
    static var defaultOrder: Self {
        [
            // we'll reverse the year groupings
            .init(\.date, order: .forward),
            .init(\.imported, order: .forward)
        ]
    }
}


// MARK: Link to Trip
extension Track: Linkable {
    func hasLink<T>(_ type: T.Type) -> Bool where T : Linkable {
        guard type == Trip.self else { return false }
        return trip != nil
    }
    func linkTo<T>(_ items: [T]) -> Bool where T : Linkable {
        guard let trip = items.compactMap({
            $0 as? Trip
        }).first else { return false }
        self.trip = trip
        trip.track = self
        self.date = trip.date
        return true
    }
    func linkedIds<T>(_ type: T.Type) -> [T.ID] where T : Linkable {
        guard type == Trip.self,
              let trip
        else { return [] }
        return [trip.id] as! [T.ID]
    }
    func unlink<T>(_ type: T.Type) where T : Linkable {
        guard type == Trip.self else { return }
        trip = nil
    }
}
