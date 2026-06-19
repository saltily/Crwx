//
//  MeasuredWaypointSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/11/25.
//

import Foundation
import FoundationSalt
import CoreLocation

struct MeasuredWaypointSnippet: Identifiable {
    var id: UUID { snippet.id }
    let snippet: WaypointSnippet
    let distance: Double
}
extension MeasuredWaypointSnippet: Mappable {
    var coordinate: CLLocationCoordinate2D { snippet.coordinate }
    var label: String? {
        let d = distance.formatted(.number.precision(.fractionLength(1)))
        if let name = snippet.name.nilIfEmpty {
            return "\(name)\n\(d)"
        }
        return d
    }
    var formattedAddress: String? { nil }
    static func make(from point: any Mappable) -> MeasuredWaypointSnippet? {
        point as? MeasuredWaypointSnippet
    }
}


extension RouteSnippet {
    func measured(from point: (any Mappable)? = nil) -> [MeasuredWaypointSnippet] {
        let i_fwd = index(nextForwardFrom: point)
        let i_rev = index(nextReversedFrom: point)
        var measured = measure(adding: point?.distance(to: points[i_rev]).converted(to: .nauticalMiles).value ?? 0, to: points[...i_rev].reversed()).reversed().map { $0 }
        measured.append(contentsOf: measure(adding: point?.distance(to: points[i_fwd]).converted(to: .nauticalMiles).value ?? 0, to: points[i_fwd...]))
        let difference = i_fwd - i_rev
//        logger.log("The difference between next forward and next reverse is: \(difference)")
        if difference == 0 {
            measured.remove(at: i_rev)
        } else if difference > 1 {
            let measuredToInsert: [MeasuredWaypointSnippet] = points[(i_rev+1)..<i_fwd].map {
                .init(snippet: $0, distance: $0.distance(to: point).converted(to: .nauticalMiles).value)
            }
            measured.insert(contentsOf: measuredToInsert, at: i_rev+1)
        }
        assert(measured.count == points.count)
//        logger.log("waypoints: \(points.count), measured: \(measured.count) and index is \(i_fwd), \(i_rev)")
        return measured
    }
    func index(nextForwardFrom point: (any Mappable)?) -> Int {
        
        // 1. Start with the nearest point
        guard let point,
              let i = index(nearestTo: point)
        else { return 0 }
        
        // 2. If we are basically this point, return it
//        logger.log("Distance to nearest is: \(point.distance(to: points[i]).converted(to: .feet).value.rounded) ft")
        if point.distance(to: points[i]).converted(to: .feet).value < 250 {
            return i
        }
        
        // 3. If this is the last point, then use it
        if (i+1) == points.count {
            return i
        }
        
        // 4. Else get course to next point
        let course = points[i+1].bearing(from: points[i])
        
        // 5. See if our bearing indicates we are ahead of or behind that point
        let bearing = points[i].bearing(from: point)
        let offset = (CompassDegree(rawValue: course.converted(to: .degrees).value.rounded) -
                      CompassDegree(rawValue: bearing.converted(to: .degrees).value.rounded)).magnitude
//        logger.info("The course forward from nearest is: \(course.converted(to: .degrees).value.rounded)\nThe bearing to nearest is: \(bearing.converted(to: .degrees).value.rounded)\nThe offset between them is: \(offset)")

        // 6. If behind the point, use it
        // offset of 0 is directly behind on course, then wings around expanding to 90 for abeam
        // once greater than 90, it's behind us and we're going to the next one
        // using 67.5 instead as that is where running lights say we are no longer behind them but abeam
        if offset < 68 {
//            logger.log("We are behind nearest.")
            return i
        } else {
//            logger.log("We are ahead of nearest.")
            return i+1
        }
    }
    func index(nextReversedFrom point: (any Mappable)?) -> Int {
        
        // 1. Start with the nearest point
        guard let point,
              let i = index(nearestTo: point)
        else { return 0 }
        
        // 2. If we are basically this point, return it
//        logger.log("Distance to nearest is: \(point.distance(to: points[i]).converted(to: .feet).value.rounded) ft")
        if point.distance(to: points[i]).converted(to: .feet).value < 250 {
            return i
        }
        
        // 3. If this is the first point, then use it
        if i == 0 {
            return i
        }
        
        // 4. Else get course to previous point
        let course = points[i-1].bearing(from: points[i])
        
        // 5. See if our bearing indicates we are ahead of or behind that point
        let bearing = points[i].bearing(from: point)
        let offset = (CompassDegree(rawValue: course.converted(to: .degrees).value.rounded) -
                      CompassDegree(rawValue: bearing.converted(to: .degrees).value.rounded)).magnitude
//        logger.info("The course reversed from nearest is: \(course.converted(to: .degrees).value.rounded)\nThe bearing to nearest is: \(bearing.converted(to: .degrees).value.rounded)\nThe offset between them is: \(offset)")
        
        // 6. If behind the point, use it
        // offset of 0 is directly behind on course, then wings around expanding to 90 for abeam
        // once greater than 90, it's behind us and we're going to the next one
        // using 67.5 instead as that is where running lights say we are no longer behind them but abeam
        if offset < 68 {
//            logger.log("We need to go back to the nearest waypoint.")
            return i
        } else {
//            logger.log("We are moving forward to the nearest waypoint.")
            return i-1
        }
    }
    func next(forward point: (any Mappable)) -> WaypointSnippet {
        points[index(nextForwardFrom: point)]
    }
    func next(reverse point: (any Mappable)) -> WaypointSnippet {
        points[index(nextReversedFrom: point)]
    }
    func mmg(at point: (any Mappable)) -> Double {
        let i = index(nextReversedFrom: point)
        return measure(adding: point.distance(to: points[i]).converted(to: .nauticalMiles).value, to: points[...i].reversed()).last?.distance ?? 0
    }
    func dtg(from point: (any Mappable)) -> Double {
        let i = index(nextForwardFrom: point)
        return measure(adding: point.distance(to: points[i]).converted(to: .nauticalMiles).value, to: points[i...]).last?.distance ?? distance
    }
    private func index(nearestTo point: (any Mappable)) -> Int? {
        guard let match = points.nearest(to: point)
        else { return nil }
        return points.firstIndex(of: match.value)
    }
    private func measure<C>(adding: Double, to waypoints: C) -> [MeasuredWaypointSnippet] where C: Collection, C.Element == WaypointSnippet {
        guard !waypoints.isEmpty else { return [] }
        var runningDistance = adding
        let waypoints = Array(waypoints)
        var lastWaypoint = waypoints[0]
        var measured: [MeasuredWaypointSnippet] = [
            .init(snippet: lastWaypoint, distance: runningDistance)
        ]
        for i in 1..<waypoints.count {
            runningDistance += lastWaypoint.distance(to: waypoints[i]).converted(to: .nauticalMiles).value
            measured.append(.init(snippet: waypoints[i], distance: runningDistance))
            lastWaypoint = waypoints[i]
        }
        return measured
    }
    private struct CompassDegree: Circular {
        var rawValue: Int
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
        static var circleSize: Int { 360 }
    }
}
