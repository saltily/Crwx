//
//  Harbour.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/17/25.
//

import Foundation
import SwiftData
import FoundationSalt
import CoreLocation
import SwiftUI
import WxSalt
import os

typealias Harbour = CurrentSchema.Harbour

extension Harbour {
    var tint: Color? {
        waypoint?.tint ?? symbol?.colour
    }
    var symbol: WaypointSymbol? {
        waypoint?.symbol
    }
    var routes: [Route]? {
        waypoint?.routes
    }
    var bottomType: BottomType? {
        get { .init(rawValue: _bottomType ?? "") }
        set { _bottomType = newValue?.rawValue }
    }
    var windExposure: CompassExposure {
        get { .init(decoding: _windExposure) ?? .init() }
        set { _windExposure = newValue.encoded}
    }
    var swellExposure: CompassExposure {
        get { .init(decoding: _swellExposure) ?? .init() }
        set { _swellExposure = newValue.encoded }
    }
    var chartDepth: Double? {
        get { _chartDepth }
        set { _chartDepth = newValue }
    }
    var entranceDepth: Double? {
        get { _entranceDepth }
        set { _entranceDepth = newValue }
    }
    var facilities: Facilities {
        get { .init(rawValue: _facilities ?? 0) }
        set { _facilities = newValue.rawValue }
    }
    var protectionScore: ProtectionScore? {
        get { .init(rawValue: _protectionScore ?? -1) }
        set { _protectionScore = newValue?.rawValue }
    }
    var guideRating: GuideRating? {
        get { .init(rawValue: _guideRating ?? -1) }
        set { _guideRating = newValue?.rawValue }
    }
    func matches(term: String) -> Bool {
        name.localizedStandardContains(term) ||
        notes.localizedStandardContains(term) ||
        protectionHighlights.localizedStandardContains(term) ||
        cruisingGuide.localizedStandardContains(term)
    }
    var cruisingGuide: CruisingGuide {
        get { .init(decoding: _cruisingGuide) ?? .init() }
        set { _cruisingGuide = newValue.encoded }
    }
    var textSample: String? {
        // 1. protection highlights
        // 2. guide anchoring
        // 3. my notes
        // 4. guide summary
        [
            protectionHighlights,
            cruisingGuide.anchoring,
            notes,
            cruisingGuide.summary
        ].compactMap {
            $0.nilIfEmpty
        }.first
    }
}

// MARK: Mappable
extension Harbour: Mappable {
    var label: String? { name }
    var formattedAddress: String? { nil }
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    static func make(from point: any Mappable) -> Harbour? {
        point as? Harbour
    }
}


// MARK: Filter
extension Harbour {
    static func find(_ id: UUID?, in context: ModelContext) -> Harbour? {
        guard let id else { return nil }
        return try? context.fetchOne(#Predicate {
            $0.id == id
        })
    }
    static func at(location: any Mappable, in context: ModelContext) -> Harbour? {
        (try? context.fetch(.harboursNear(point: location, radius: .init(value: Trip.harbourThreshold, unit: .nauticalMiles))).sorted(by: {
            $0.distance(to: location) < $1.distance(to: location)
        }))?.first
    }
}
extension Predicate {
    static func harboursNear(point: any Mappable, radius: Measurement<UnitLength>) -> Predicate<Harbour> {
        let box = MapBox(point: point, radius: radius)
        let left = box.left
        let right = box.right
        let top = box.top
        let bottom = box.bottom
        return #Predicate {
            $0.latitude >= bottom &&
            $0.latitude <= top &&
            $0.longitude >= left &&
            $0.longitude <= right
        }
    }
}
extension [SortDescriptor<Harbour>] {
    static var eastToWest: Self {
        [
            .init(\.longitude, order: .reverse),
            .init(\.latitude, order: .reverse)
        ]
    }
}
extension Collection where Element == Harbour {
    func organised() -> [Harbour] {
        guard !self.isEmpty else { return [] }
        var organised = [Harbour]()
        var remaining = self.sorted(by: [.init(\.longitude, order: .reverse), .init(\.latitude, order: .reverse)])
        var current = remaining.removeFirst()
        organised.append(current)
        while !remaining.isEmpty {
            let nearNeighbours = remaining.filter {
                $0.distance(to: current) < 2.nauticalMiles
            }
            if !nearNeighbours.isEmpty {
                organised.append(contentsOf: nearNeighbours)
                remaining.removeAll(where: {
                    nearNeighbours.contains($0)
                })
            }
            if !remaining.isEmpty {
                current = remaining.removeFirst()
                organised.append(current)
            }
        }
        return organised
    }
}

// MARK: Forecast Locations
extension Harbour {
    var tideStation: TideStation {
        get {
            if let decoded = TideStation(decoding: _tideStation) { return decoded }
            if let nearest = TideStation.nearest(to: self) {
                _tideStation = nearest.encoded
                return nearest
            }
            return .default
        }
        set {
            _tideStation = newValue.encoded
        }
    }
//    var _tidalCurrentStation: Data?
    var marineZone: MarineZone {
        get {
            if let decoded = MarineZone(decoding: _marineZone) { return decoded }
            if let nearest = MarineZone.nearest(to: self) {
                _marineZone = nearest.encoded
                return nearest
            }
            return .default
        }
        set {
            _marineZone = newValue.encoded
        }
    }
//    var _marinePoint: Data?
}


// MARK: Web Sharing
extension Harbour: Encodable {
    enum CodingKeys: CodingKey {
        case uuid, id, name, latitude, longitude, bottomType, chartDepth, entranceDepth, windExposure, swellExposure, notes, rating, guideRating, facilities, protectionScore, protectionHighlights, cruisingGuide, tideStation, tidalCurrentStation, marineZone, marinePoint
    }
    /// This is specifically to send json to website for sharing
    /// If I know I'm not going to display something on the website, I can skip including it
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .uuid)
        try container.encodeIfPresent(webId, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
//        try container.encodeIfPresent(bottomType?.rawValue, forKey: .bottomType)
//        try container.encodeIfPresent(chartDepth, forKey: .chartDepth)
//        try container.encodeIfPresent(entranceDepth, forKey: .entranceDepth)
//        try container.encodeIfPresent(windExposure, forKey: .windExposure)
//        try container.encodeIfPresent(swellExposure, forKey: .swellExposure)
        try container.encode(notes, forKey: .notes)
//        try container.encodeIfPresent(rating, forKey: .rating)
//        try container.encodeIfPresent(guideRating, forKey: .guideRating)
//        try container.encodeIfPresent(facilities, forKey: .facilities)
//        try container.encodeIfPresent(protectionScore, forKey: .protectionScore)
//        try container.encode(protectionHighlights, forKey: .protectionHighlights)
        try container.encodeIfPresent(cruisingGuide, forKey: .cruisingGuide)
//        try container.encodeIfPresent(tideStation, forKey: .tideStation)
//        try container.encodeIfPresent(tidalCurrentStation, forKey: .tidalCurrentStation)
//        try container.encodeIfPresent(marineZone, forKey: .marineZone)
//        try container.encodeIfPresent(marinePoint, forKey: .marinePoint)

    }
}
extension Harbour: WebShareable {
    @MainActor
    func share(_ context: ModelContext) async throws -> URL {
        if let id = self.webId {
            let url = URL(string: "https://www.saltily.com/blouse/update-harbour")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = self.json
            let (data, _) = try await URLSession.shared.data(for: request)
            if let string = String(data: data, encoding: .utf8) {
                logger.trace("\(string)")
            }
            guard let result = try WebShareResult(json: data)
            else {
                throw WebShareResult.E.InvalidResponse
            }
            if let error = result.error {
                throw WebShareResult.E.Online(error)
            }
            if let success = result.success {
                logger.info("\(success)")
            }
            return URL(string: "https://www.saltily.com/blouse/harbour?id=\(id)")!
        }
        else {
            let url = URL(string: "https://www.saltily.com/blouse/upload-harbour")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = self.json
            let (data, _) = try await URLSession.shared.data(for: request)
            guard let result = try WebShareResult(json: data)
            else { throw WebShareResult.E.InvalidResponse }
            if let error = result.error {
                throw WebShareResult.E.Online(error)
            }
            guard let id = result.id
            else { throw WebShareResult.E.InvalidResponse }
            self.webId = id
            try context.save()
            return URL(string: "https://www.saltily.com/blouse/harbour?id=\(id)")!
        }
    }
}
