//
//  Route.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import Foundation
import SwiftData
import FoundationSalt

typealias Route = CurrentSchema.Route

extension Route {
    var waypointIds: [UUID] {
        get { .init(decoding: _waypoints) ?? [] }
        set { _waypoints = newValue.encoded }
    }
    var start: P? {
        guard let idString = endpointIds.components(separatedBy: " - ").first,
              let id = UUID(uuidString: idString),
              let name = endpointNames.components(separatedBy: " - ").first,
              let stamp = endpointStamps.components(separatedBy: " - ").first
        else { return nil }
        return .init(id: id, name: name, stamp: stamp)
    }
    var end: P? {
        guard let idString = endpointIds.components(separatedBy: " - ").last,
              let id = UUID(uuidString: idString),
              let name = endpointNames.components(separatedBy: " - ").last,
              let stamp = endpointStamps.components(separatedBy: " - ").last
        else { return nil }
        return .init(id: id, name: name, stamp: stamp)
    }
    struct P: Comparable, Hashable {
        let id: UUID
        let name: String
        let stamp: String
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.stamp > rhs.stamp
        }
    }
    func waypoints(in context: ModelContext) throws -> [Waypoint] {
        try Waypoint.mapping(waypointIds, in: context)
    }
    func ends(in context: ModelContext) throws -> (start: Waypoint, end: Waypoint) {
        let ids = waypointIds
        guard ids.count > 1,
              let first = ids.first,
              let last = ids.last
        else { throw BackModelActor.E.EmptyRoute }
        let ends = try Waypoint.mapping([first, last], in: context)
        return (ends[0], ends[1])
    }
    func restamp(in context: ModelContext) throws {
        let (start,end) = try ends(in: context)
        endpointIds = .endpointIds(start, end)
        endpointNames = .endpointNames(start, end)
        endpointStamps = .endpointStamps(start, end)
        if name.contains(" to ") || name.isEmpty {
            name = "\(start.name) to \(end.name)"
        }
    }
    func regenerateName() {
        name = endpointNames.components(separatedBy: " - ").joined(separator: " to ")
    }
    func end(not id: UUID, in context: ModelContext) -> Waypoint? {
        guard let (start,end) = try? ends(in: context) else { return nil }
        if start.id != id { return start }
        if end.id != id { return end }
        return nil
    }
}
extension [Route] {
    func sorted(not id: UUID, in context: ModelContext) -> [Route] {
        self.sorted { lhs, rhs in
            if lhs.length == rhs.length {
                let lhe = lhs.end(not: id, in: context)
                let rhe = rhs.end(not: id, in: context)
                if let lhe, let rhe {
                    return lhe.longitude < rhe.longitude
                }
                return lhe != nil
            }
            return lhs.length < rhs.length
        }
    }
    func allWaypoints(in context: ModelContext) -> [Waypoint] {
        let ids = self.flatMap {
            $0.waypointIds
        }.set
        return (try? context.fetch(#Predicate {
            ids.contains($0.id)
        })) ?? []
    }
}

// MARK: Fetching
extension Route {
    static func find(_ id: UUID?, in context: ModelContext) -> Route? {
        guard let id else { return nil }
        return try? context.fetchOne(#Predicate {
            $0.id == id
        })
    }
}
extension [SortDescriptor<Route>] {
    static var defaultOrder: Self {
        [
            .init(\.endpointStamps, order: .reverse)
        ]
    }
}
