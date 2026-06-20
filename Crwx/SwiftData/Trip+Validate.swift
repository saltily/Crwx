//
//  Trip+Validate.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/12/24.
//

import Foundation

extension Trip {
    func validate(tripDate: Date) throws {
        // must be before departure
        if let departureTime {
            guard tripDate <= departureTime
            else { throw "Trip date must be before departure time" }
            // should be same day as departure
            guard tripDate.withoutTime == departureTime.withoutTime
            else { throw "Trip date should be same day as departure" }
        }
    }
    func validate(departureTime: Date?) throws {
        if let departureTime {
            // if arrived, cannot be nil
            guard departureTime >= date
            else { throw "Trip date must be before departure time" }
            // must be same day as trip date
            guard departureTime.withoutTime == date.withoutTime
            else {
                throw "Trip must depart on same day as trip date"
            }
            if let arrivalTime {
                // must be before arrival
                guard departureTime <= arrivalTime
                else { throw "Trip must depart before arriving" }
            }
        }
        else {
            // if arrived, cannot be nil
            guard arrivalTime == nil
            else { throw "Trip must have departed before arriving" }
        }
    }
    /// Cast the date to something that would be valid for this trip
    func valid(departureTime: Date?) -> Date? {
        guard let departureTime else { return nil }
        do {
            try validate(departureTime: departureTime)
            return departureTime
        }
        catch {
            let t = date.withoutTime.addingTimeInterval(departureTime.timeAsInterval)
            if t < date {
                return date
            }
            else if let arrivalTime,
                    t > arrivalTime
            {
                return arrivalTime
            }
            else {
                return t
            }
        }
    }
    func validate(arrivalTime: Date?) throws {
        // must have departed
        guard let departureTime
        else { throw "Trip must depart before arriving" }
        // must be after departure
        if let arrivalTime {
            guard arrivalTime >= departureTime
            else { throw "Trip must arrive after departing" }
        }
    }
}
