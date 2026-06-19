//
//  SailingSnapshotViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/13/25.
//

import Foundation
import FoundationSalt
import CoreLocation
import WxSalt

@Observable
final class SailingSnapshotViewModel {
    init(startTime: Date, route: RouteSnippet, startHarbour: Harbour, endHarbour: Harbour, currentLocation: any Mappable, currentTime: Date) {
        self.startTime = startTime
        self.route = route
        self.startHarbour = startHarbour
        self.endHarbour = endHarbour
        self.currentLocation = currentLocation
        self.currentTime = currentTime
        refresh(time: currentTime, location: currentLocation)
    }
    let startTime: Date
    private(set) var route: RouteSnippet
    let startHarbour: Harbour
    let endHarbour: Harbour
    var currentLocation: any Mappable
    var currentTime: Date
    
    // cache
    var mmg: Double = 0
    var dtg: Double = 0
    /// Calculate from miles made good and time lapsed (minus the first 15 minutes)
    var smg: Double?
    /// Actual current speed
    var spd: Double? // actual current speed
    /// Actual current heading
    var hdg: Measurement<UnitAngle>? // actual heading
    var history: [PositionStamp] = []
    
    // customisation
    var tripMiles: Double?
    var sog: Double?
    
    struct PositionStamp: Mappable {
        init(time: Date, location: (any Mappable)) {
            self.time = time
            self.stamp = time.timeIntervalSince1970
            self.location = location.coordinate
        }
        let time: Date
        let stamp: Double // microseconds precision
        let location: CLLocationCoordinate2D
        var label: String? { time.formatted(.dateTime.hour().minute()) }
        var coordinate: CLLocationCoordinate2D { location }
        static func make(from point: any Mappable) -> SailingSnapshotViewModel.PositionStamp? {
            point as? Self
        }
        var formattedAddress: String? { nil }
    }
}

extension SailingSnapshotViewModel {
    func refresh(time: Date = .now, location: any Mappable) {
        self.currentLocation = location
        self.currentTime = time
        history.append(.init(time: time, location: location))
        // we can always safely do these two
        let mmg = route.mmg(at: location)
        let dtg = route.dtg(from: location)
        self.mmg = mmg
        self.dtg = dtg
        // smg is unreliable in the first 15 minutes where we're typically spinning around and setting sail
        // then let us sail for another 15 minutes after that before trying to estimate it so it can cushion it out if we actually did move a lot in the first 15 minutes - because we're using the whole distance but only the time after 15
        if let timeLapsed,
           timeLapsed > 15.minute
        {
            let hoursLapsed = timeLapsed / .Hour
            let smg = mmg / hoursLapsed
            self.smg = smg.nilIfTooFast
        }
        // current speed and heading are based on sufficient history
        updateCurrentSpeedAndHeading()
    }
    func updateCurrentSpeedAndHeading() {
        // let's base it off of the last 10 seconds
        let recent = history.filter {
            $0.time.timeIntervalSinceNow > -10.5
        }
        guard recent.count >= 2,
              let oldest = recent.first,
              let newest = recent.last
        else {
            spd = nil
            hdg = nil
            return
        }
        let secondsLapsed = newest.stamp - oldest.stamp
        guard secondsLapsed.rounded > 5 else {
            spd = nil
            hdg = nil
            return
        }
        let distance = oldest.distance(to: newest)
        let speed = distance / secondsLapsed
        let spd = speed.converted(to: .knots).value
        self.spd = spd.nilIfTooFast
        hdg = spd < 0.01 || self.spd == nil ? nil : newest.bearing(from: oldest)
    }
    func set(route: RouteSnippet) {
        self.route = route
        let mmg = route.mmg(at: currentLocation)
        let dtg = route.dtg(from: currentLocation)
        let hoursLapsed = currentTime.timeIntervalSince(startTime) / .Hour
        let smg = mmg / hoursLapsed
        self.mmg = mmg
        self.dtg = dtg
        self.smg = smg
    }
}

extension SailingSnapshotViewModel {
    var eta: Date? {
        guard let ttg else { return nil }
        return currentTime.addingTimeInterval(ttg)
    }
    var estimatedTotalTime: TimeInterval? {
        guard let eta else { return nil }
        return eta.timeIntervalSince(startTime)
    }
    var timeLapsed: TimeInterval? {
        let timeLapsed = currentTime.timeIntervalSince(startTime) - 15.minute
        if timeLapsed < 0 { return nil }
        return timeLapsed
    }
    var computedSog: Double? {
        guard let timeLapsed else { return nil }
        let mmg = tripMiles ?? self.mmg
        let hoursLapsed = timeLapsed / .Hour
        return (mmg / hoursLapsed).nilIfTooFast
    }
    var ttg: TimeInterval? {
        guard let spd = sog ?? smg
        else { return nil }
        return (dtg / spd).hour
    }
    var destinationName: String {
        route.points.last?.name ?? ""
    }
    var timeUnderway: TimeInterval {
        currentTime.timeIntervalSince(startTime)
    }
//    var allPoints: [CLLocationCoordinate2D] {
//        route.points.map { $0.coordinate } + [currentLocation.coordinate]
//    }
    var rangeInHour: Measurement<UnitLength> {
        let spd = spd ?? 3.0
        return .init(value: spd, unit: .nauticalMiles)
    }
}

fileprivate extension Double {
    var nilIfTooFast: Double? {
        if self > 15 { return nil }
        return self
    }
}
