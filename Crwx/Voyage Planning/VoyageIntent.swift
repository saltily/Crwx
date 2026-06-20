//
//  VoyageIntent.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/27/25.
//

import Foundation
import SwiftData
import CoreLocation
import FoundationSalt

struct VoyageIntent: Equatable, Mappable {
    // on a form, all fields describe the default and a button to reset to default after customising
    // MARK: From Where to…
    /// Base distances on this harbour as the starting point
    /// Default to where the sailboat currently is
    var start: UUID
    var startName: String
    var coordinate: CLLocationCoordinate2D
    var formattedAddress: String? { nil }
    /// Typically whether we're trending to the west or to the east
    /// Used to filter results, and estimate speed based on whether we're fighting the wind and current
    /// If the boat is at home, default to west.  If we have left home, assume eastward or westward trend from yesterday.  Or if the boat shifted a while ago, assume we'll want to head home.
    var directionOfTravel: CompassQuadrant
    /// For when the trip has already started and we're partiall departed from the start.
    var fromLocation: CLLocationCoordinate2D?

    // MARK: Times
    /// What time we expect to depart.
    /// Helps determine eta at various ports.  And when to look at the tides and weather
    /// Default to an hour from now, or if it is after dark, default to sunrise or 0700.  Should let us choose to be ambitious if we want to maximise the day.
    var estimatedDeparture: Date
    /// When we want to be anchored by.
    /// Helps filter out how far we might be able to travel.  Also establishes the conditions that would affect our speed during travel.
    /// Default to one hour before sunset after estimated departure.  Should give us a cushion if we overshoot.
    var preferredArrival: Date
    /// What time we expect to depart this new destination.
    /// Helps establish the conditions we need to be protected from in the next anchorage.
    /// Defaults to 1000 the next day after preferred arrival.  Should give us a cushion if we overstay our welcome.
    var stayUntil: Date
    
    // MARK: Speed
    /// Estimated speed we will make good in the direction of travel between estimated departure and preferred arrival.
    /// Depends on the marine wind and wave forecast, tides, and our direction of travel.  This is used to calculate ETAs.  I want to be able to customise it.  But also I wonder about asking for this at different hours since we might over or underestimate if we don't travel all day.  That being said, though, it shouldn't overshoot because we would fill the day.
    var estimatedSpeed: Double
//    var speedJustification: String {} // explain why that is the speed estimate
//    var directionOfFlood: CompassQuadrant // to help estimate speed (usually flooding east)
//    var winds: WindForecast // to help with speed and security at anchorage, though this is more per anchorage, so it's just the speed we care about here - except the nice thing about putting it more here is that I could customise it if I'm having trouble getting forecasts - I think I'd mostly want the offshore marine forecast for this one
//    var waves: WaveForecast // actually on the individual destinations will care about this one
}


// MARK: Init
extension VoyageIntent {
    init(harbour: Harbour? = nil, direction: CompassQuadrant = .west, night: Day = .today, speed: Double = 2.0) {
        self.start = harbour?.id ?? .init()
        self.startName = harbour?.name ?? "--"
        self.coordinate = harbour?.coordinate ?? .default
        directionOfTravel = direction
        (self.estimatedDeparture, self.preferredArrival, self.stayUntil) = Self.defaultTimes(day: night, at: harbour?.coordinate ?? .default)
        estimatedSpeed = speed
    }
}


// MARK: Derived
extension VoyageIntent {
    var timeUnderway: Double {
        preferredArrival.timeIntervalSince(estimatedDeparture)
    }
    var timeAtAnchor: Double {
        stayUntil.timeIntervalSince(preferredArrival)
    }
    var timeSummary: String {
        let hoursUnderway = timeUnderway / .Hour
        let hoursAtAnchor = timeAtAnchor / .Hour
        return "\(hoursUnderway.rounded.appending("hour", "hours")) underway, \(hoursAtAnchor.rounded.appending("hour", "hours")) at anchor"
    }
    var timesAreValid: Bool {
        preferredArrival > estimatedDeparture &&
        stayUntil > preferredArrival
    }
    var range: Double {
        timeUnderway / .Hour * estimatedSpeed
    }
    var label: String? {
        estimatedDeparture.formatted(.dateTime.hour().minute())
    }
    static func make(from point: any Mappable) -> VoyageIntent? {
        point as? Self
    }
    var summary: String {
        let speed = estimatedSpeed.formatted(.number.precision(.fractionLength(0...1)))
        let hoursUnderway = timeUnderway / .Hour
        let hours = hoursUnderway.rounded.appending("hr", "hrs")
        let distance = range.rounded
        return "\(startName) \(directionOfTravel) \(distance) nm, \(hours), \(speed) kts"
    }
    var timeRange: String {
        let from = estimatedDeparture.formatted(.dateTime.hour().minute())
        let to = preferredArrival.formatted(.dateTime.hour().minute())
        return "\(from) to \(to)"
    }
    var departureHour: TimeInterval {
        get { estimatedDeparture.timeIntervalSinceReferenceDate.rounded(.Hour) }
        set { estimatedDeparture = .init(timeIntervalSinceReferenceDate: newValue) }
    }
    var arrivalHour: TimeInterval {
        get { preferredArrival.timeIntervalSinceReferenceDate.rounded(.Hour) }
        set { preferredArrival = .init(timeIntervalSinceReferenceDate: newValue) }
    }
    var sunrise: Date {
        estimatedDeparture.sunrise(at: self)
    }
    var sunset: Date {
        preferredArrival.sunset(at: self)
    }
    var dayDescription: String {
        ""
    }
}


// MARK: Day Stepping
extension VoyageIntent {
    mutating func tomorrow() {
        (self.estimatedDeparture, self.preferredArrival, self.stayUntil) = Self.defaultTimes(day: preferredArrival.day.tomorrow, at: self)
    }
    mutating func yesterday() {
        (self.estimatedDeparture, self.preferredArrival, self.stayUntil) = Self.defaultTimes(day: preferredArrival.day.yesterday, at: self)
    }
    mutating func setStart(_ harbour: Harbour) {
        start = harbour.id
        startName = harbour.name
        coordinate = harbour.coordinate
    }
    static func defaultTimes(day: Day, at point: any Mappable) -> (Date, Date, Date) {
        let sunrise = day.start.sunrise(at: point)
        let sunset = day.start.sunset(at: point)
        let arrival = sunset.subtractingTimeInterval(1.hour).rounded(10.minute, .down)
        var departure = day.start.addingTimeInterval(9.hour)
        if departure < sunrise {
            departure = sunrise.rounded(10.minute, .up)
        }
        if day.isToday {
            let earliest = Date.now.addingTimeInterval(30.minute)
            let latest = arrival.subtractingTimeInterval(1.hour)
            if departure < earliest {
                departure = earliest.rounded(10.minute, .up)
            }
            if departure > latest {
                departure = latest.rounded(10.minute, .down)
            }
        }
        return (departure, arrival, day.tomorrow.start.addingTimeInterval(10.hour))
    }
}
