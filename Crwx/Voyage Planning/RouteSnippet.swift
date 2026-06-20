//
//  RouteSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import Foundation
import FoundationSalt
import FoundationUI

/// Really just to cache the length
struct RouteSnippet: Comparable, Identifiable, nonisolated Hashable, Codable, Sendable {
    let id: String
    var points: [WaypointSnippet]
    let distance: Double
    let generated: Bool
    var sourceId: UUID?
}

extension RouteSnippet {
    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    var legs: [RouteSnippet] {
        guard points.count > 2 else { return [self] }
        var reader = points.reader
        var lhs = reader.read()
        var legs = [RouteSnippet]()
        while !reader.didReachEnd {
            let rhs = reader.read()
            legs.append(.init([lhs,rhs], generated: true))
            lhs = rhs
        }
        return legs
    }
    var name: String {
        "\(points.first?.name ?? "") to \(points.last?.name ?? "")"
    }
    var bearing: Measurement<UnitAngle>? {
        points.last?.bearing(from: points.first)
    }
}

extension RouteSnippet {
    init(_ points: [WaypointSnippet], generated: Bool, sourceId: UUID? = nil) {
        self.id = points.stamp
        self.points = points
        self.distance = points.totalDistance.converted(to: .nauticalMiles).value
        self.generated = generated
        self.sourceId = sourceId
    }
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.distance < rhs.distance
    }
    func appending(_ continuation: RouteSnippet) throws -> RouteSnippet {
        guard continuation.points.first?.id == points.last?.id else { throw RouteLoader.E.InvalidContinuation }
        var points = self.points
        points.removeLast()
        points.append(contentsOf: continuation.points)
        return .init(points, generated: true)
    }
    func connects(_ start: any Mappable, to end: any Mappable) -> Bool {
        guard let first = points.first,
              let last = points.last
        else { return false }
        return start.distance(to: first).converted(to: .nauticalMiles).value < 0.25 &&
        end.distance(to: last).converted(to: .nauticalMiles).value < 0.25
    }
}

// MARK: Codable
extension RouteSnippet {
    enum CodingKeys: CodingKey {
        case id, points, distance, generated, sourceId
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        points = try container.decode([WaypointSnippet].self, forKey: .points)
        distance = try container.decode(Double.self, forKey: .distance)
        generated = try container.decode(Bool.self, forKey: .generated)
        sourceId = try container.decodeIfPresent(UUID.self, forKey: .sourceId)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(points, forKey: .points)
        try container.encode(distance, forKey: .distance)
        try container.encode(generated, forKey: .generated)
        try container.encodeIfPresent(sourceId, forKey: .sourceId)
    }
}


// MARK: Map Tiles
extension RouteSnippet {
    /// For preloading along the route
    var mapTiles: Set<MapTileBox> {

        // 1. Start with a 14/y/x-3x5 containing the point at either end
        guard let first = points.first,
              let last = points.last
        else { return [] }
        var fourteens: [MapTileBox] = [
            .init(point: first, zoom: 14, width: 3, height: 5),
            .init(point: last, zoom: 14, width: 3, height: 5)
        ]
        
        // 2. Do the 15s. Divide each 14 into 15 and expand those out one in all directions.
        var fifteens: Set<MapTileBox> = fourteens.flatMap {
            $0.children(at: 15)
        }.set
        
        // 3. Do the 16s. Divide all 15s into 16s.
        let sixteens: Set<MapTileBox> = fifteens.flatMap {
            $0.children(at: 16)
        }.set
        fifteens = fifteens.flatMap {
            $0.echo(1)
        }.set
        
        // 4. Do the 14s. Connecting the endpoint 14s along each route segment. Then expand each out by one in all directions.
        var current = fourteens[0]
        for leg in self.legs {
            let a = leg.points[0]
            let b = leg.points[1]
            var next = current.nextBox(from: a, to: b)
            while let n = next,
                  n != current
            {
                fourteens.append(n)
                current = n
                next = current.nextBox(from: a, to: b)
            }
        }
        
        // 5. Do the 13, 12, 11, 10, 9, 8. Collapse all 14/15/16 into their parents.
        let upclose = fourteens.set.union(fifteens).union(sixteens)
        let outfar: Set<MapTileBox> = (8...13).flatMap { z in
            upclose.map {
                $0.parent(at: z)
            }
        }.set
        
        return upclose.union(outfar)
    }
}
