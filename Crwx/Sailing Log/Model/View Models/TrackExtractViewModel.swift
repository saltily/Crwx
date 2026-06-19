//
//  TrackExtractViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/10/25.
//

import Foundation
import SwiftData

struct TrackExtractViewModel: Identifiable {
    init(segment: [TrackPoint], original: Track) {
        let date = segment.first?.time?.withoutTime
        self.date = date ?? original.date
        if let date {
            let day = date.formatted(.dateTime.day(.twoDigits))
            let month = date.formatted(.dateTime.month()).uppercased()
            let year = date.formatted(.dateTime.year(.twoDigits))
            name = "\(day)-\(month)-\(year)"
        } else {
            name = "\(original.name) <slice>"
        }
        points = [segment]
        self.original = original
        let (distance, duration, speed, gain) = segment.measure()
        self.distance = distance
        self.duration = duration
        self.speed = speed
        self.elevationGain = gain
        self.stamp = .stamp(points: segment)
    }
    let id: UUID = .init()
    var name: String = ""
    var date: Date?
    let points: [[TrackPoint]]
    let original: Track
    let distance: Double
    let duration: TimeInterval?
    let speed: Double?
    let elevationGain: Double?
    let stamp: String
}


extension TrackExtractViewModel {
    func insert(into context: ModelContext) {
        let new = Track(
            id: .init(),
            name: name,
            date: date,
            _points: points.encoded,
            distance: distance,
            duration: duration,
            averageSpeed: speed,
            elevationGain: elevationGain,
            imported: original.imported,
            source: original.source,
            stamp: stamp
        )
        context.insert(new)
    }
}
