//
//  TrackPoint.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import Foundation
import FoundationSalt
import CoreLocation
import CoreGraphics

struct TrackPoint: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    /// In feet.
    let elevation: Double?
    let time: Date?
    var isHidden: Bool = false
}

extension TrackPoint: Mappable {
    var label: String? {
        time?.formatted(.dateTime.hour().minute())
    }
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    var formattedAddress: String? { nil }
    static func make(from point: any Mappable) -> TrackPoint? {
        .init(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude, elevation: nil, time: nil)
    }
}
extension [TrackPoint] {
    /// Measures the distance in nautical miles, duration if there are times, average speed if there are times, and elevation gain if there is elevation.
    func measure() -> (distance: Double, duration: TimeInterval?, speed: Double?, gain: Double?) {
        let visible = self.visible
        let distance = visible.totalDistance.converted(to: .nauticalMiles).value
        let duration: TimeInterval?
        let averageSpeed: Double?
        if let start = visible.first?.time,
           let end = visible.last?.time
        {
            duration = end.timeIntervalSince(start)
            if duration == 0 { averageSpeed = 0 }
            else { averageSpeed = distance / (duration! / .Hour) }
        } else {
            duration = nil
            averageSpeed = nil
        }
        #warning("Elevation gain, the order matters?")
        let elevationGain: Double?
        let elevations = visible.compactMap {
            $0.elevation
        }.sorted()
        if let low = elevations.first,
           let high = elevations.last
        {
            elevationGain = high - low
        } else { elevationGain = nil }
        return (distance, duration, averageSpeed, elevationGain)
    }
    var visible: Self {
        self.filter {
            !$0.isHidden
        }
    }
}
extension [[TrackPoint]] {
    /// It's erasable if there is one and only one visible track point within 3 metres of this origin
    func erasable(at origin: CLLocationCoordinate2D) -> (Int, Int)? {
        let box = origin.radius(.init(value: 3, unit: .meters))
        var match: (Int, Int)?
        for i in 0..<self.count {
            let segment = self[i]
            for j in 0..<segment.count {
                if !segment[j].isHidden,
                   box.contains(segment[j].cgPoint)
                {
                    guard match == nil else { return nil }
                    match = (i, j)
                }
            }
        }
        return match
    }
    /// It's erasable if this point is within 3 metres of one and only one visible line between two track points
    func sliceable(at origin: CLLocationCoordinate2D) -> (Int, Int)? {
        var match: (Int, Int)?
        for i in 0..<self.count {
            var reader = self[i].reader
            guard reader.countRemainder >= 2 else { continue }
            var lhs = reader.read()
            var rhs = reader.read()
            while !reader.didReachEnd {
                guard !lhs.isHidden else {
                    lhs = rhs
                    rhs = reader.read()
                    continue
                }
                guard !rhs.isHidden else {
                    rhs = reader.read()
                    continue
                }
                if origin.is(between: lhs, and: rhs) {
                    guard match == nil else { return nil }
                    match = (i,reader.currentIndex - 1)
                }
                lhs = rhs
                rhs = reader.read()
            }
        }
        return match
    }
    var allVisible: [TrackPoint] {
        self.flatMap {
            $0.visible
        }
    }
    subscript(path path: (Int, Int)?) -> TrackPoint? {
        get {
            guard let path else { return nil }
            return self[path.0][path.1]
        }
        set {
            if let path,
               let newValue
            {
                self[path.0][path.1] = newValue
            }
        }
    }
}

// MARK: Codable
extension TrackPoint {
    enum CodingKeys: CodingKey {
        case latitude, longitude, elevation, time, isHidden
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        elevation = try container.decodeIfPresent(Double.self, forKey: .elevation)
        time = try container.decodeIfPresent(Date.self, forKey: .time)
        isHidden = try container.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encodeIfPresent(elevation, forKey: .elevation)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encode(isHidden, forKey: .isHidden)
    }
}
