//
//  GpxParser.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import Foundation
import SWXMLHash
import WxSalt

// MARK: Init
struct GpxParser {
    let url: URL?
    let creator: String?
    let time: String?
    let size: Int64
    let waypointTrees: [XMLIndexer]
    let trackTrees: [XMLIndexer]
    let dateFormatter = ISO8601DateFormatter()
    let nameDateFormatter: DateFormatter
    init?(url: URL) throws {
        self.init(data: try Data(contentsOf: url), url: url)
    }
    init?(data: Data, url: URL? = nil) {
        self.url = url
        let xml = XMLHash.parse(data)
        guard xml["gpx"].all.count == 1 else { return nil }
        creator = xml["gpx"].element?[attribute: "creator"]?.text
        time = xml["gpx"]["metadata"]["time"].element?.text
        size = Int64(data.count)
        waypointTrees = xml["gpx"]["wpt"].all
        trackTrees = xml["gpx"]["trk"].all
        self.nameDateFormatter = .init()
        nameDateFormatter.dateFormat = "dd-MMM-yy"
    }
}


// MARK: Waypoints
extension GpxParser {
    /// The returned waypoint has not been inserted into a context yet, and it doesn't watch for deduplication
    func waypoint(at i: Int) throws -> Waypoint {
        let indexer = waypointTrees[i]
        guard let lat = indexer.element?[attribute: "lat"]?.text,
              let lon = indexer.element?[attribute: "lon"]?.text
        else { throw ParseError.MissingRequiredProperty }
        guard let latitude = Double(lat),
              let longitude = Double(lon)
        else { throw ParseError.InvalidPropertyValue }
        let created: Date?
        if let time = indexer["time"].element?.text {
            // 2018-09-24T21:41:16Z
            guard let d = dateFormatter.date(from: time)
            else { throw ParseError.InvalidPropertyValue }
            created = d
        } else { created = nil }
        return Waypoint(
            id: .init(),
            source: creator ?? "",
            latitude: latitude,
            longitude: longitude,
            name: indexer["name"].element?.text ?? "",
            _symbol: indexer["sym"].element?.text,
            created: created,
            imported: .now,
            stamp: .stamp(latitude: latitude, longitude: longitude)
        )
    }
}
extension String {
    /// There are 364,320 feet in a degree of latitude.  5 decimal places is within 4 feet.
    static func stamp(latitude: Double, longitude: Double) -> String {
        "\(latitude.rounded(0.00001).formatted(.number.precision(.fractionLength(5)))),\(longitude.rounded(0.00001).formatted(.number.precision(.fractionLength(5))))"
    }
}


// MARK: Tracks
extension GpxParser {
    /// The returned track has not been inserted into a context yet, and it doesn't watch for deduplication
    func track(at i: Int) throws -> Track {
        let indexer = trackTrees[i]
        let name = indexer["name"].element?.text
        let segments = try indexer["trkseg"].all.map {
            try trackSegment($0)
        }
        // Getting the date
        // Gaia records time in the points along the track
        // Garmin names it like 25-SEP-18
        let date: Date?
        if let d = segments.first?.first?.time {
            date = d
        } else if let name,
                  name.matches(expression: "^\\d{2}-[A-Z]{3}-\\d{2}$".expression)
        {
            if let d = nameDateFormatter.date(from: name) {
                date = d
            } else {
                logger.critical("Couldn't parse date from \(name)")
                date = nil
            }
        }
        else { date = nil }
        // Distance, speed, and elevation
        let points = segments.flatMap { $0 }
        let (distance, duration, speed, gain) = points.measure()
        return Track(
            id: .init(),
            name: name ?? "",
            date: date,
            _points: segments.encoded,
            distance: distance,
            duration: duration,
            averageSpeed: speed,
            elevationGain: gain,
            imported: .now,
            source: creator ?? "",
            stamp: .stamp(points: points)
        )
    }
    private func trackSegment(_ indexer: XMLIndexer) throws -> [TrackPoint] {
        try indexer["trkpt"].all.map {
            try trackPoint($0)
        }
    }
    private func trackPoint(_ indexer: XMLIndexer) throws -> TrackPoint {
        guard let lat = indexer[attribute: "lat"]?.text,
              let lon = indexer[attribute: "lon"]?.text
        else { throw ParseError.MissingRequiredProperty }
        guard let latitude = Double(lat),
              let longitude = Double(lon)
        else { throw ParseError.InvalidPropertyValue }
        let elevation: Double?
        if let ele = indexer["ele"].element?.text {
            guard let e = Double(ele)
            else { throw ParseError.InvalidPropertyValue }
            elevation = e
        } else { elevation = nil }
        let time: Date?
        if let tm = indexer["time"].element?.text {
            guard let t = dateFormatter.date(from: tm)
            else { throw ParseError.InvalidPropertyValue }
            time = t
        } else { time = nil }
        return .init(
            latitude: latitude,
            longitude: longitude,
            elevation: elevation,
            time: time
        )
    }
}
extension String {
    static func stamp(points: [TrackPoint]) -> String {
        "\(points.count),\(points.encoded?.count ?? 0)"
    }
}


// MARK: Tracker Setup
extension GpxParser {
    var count: Int {
        waypointTrees.count + trackTrees.count
    }
}
extension [GpxParser] {
    var totalCount: Int {
        self.reduce(0) { partialResult, parser in
            partialResult + parser.count
        }
    }
}
enum ParseError: Error {
    case MissingRequiredProperty
    case InvalidPropertyValue
    case InvalidDate
    case InvalidUUID
    case InvalidCoordinate
    case InvalidDistance
    case MissingRouteEndpoint
    case MissingRouteWaypoint
}

// MARK: Debug
extension GpxParser: CustomDebugStringConvertible {
    var debugDescription: String {
"""
GpxParser(
    file: \(url?.lastPathComponent ?? "")
    size: \(size.formatted(.byteCount(style: .file)))
    creator: \(creator ?? "")
    time: \(time ?? "")
    waypoints: \(waypointTrees.count)
    tracks: \(trackTrees.count)
)
"""
    }
}
