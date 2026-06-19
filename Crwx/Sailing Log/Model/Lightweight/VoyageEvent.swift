//
//  VoyageEvent.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import FoundationSalt
import CoreLocation

struct VoyageEvent: Codable, Identifiable, Equatable {
    var id: UUID = .init()
    var time: Date = .now
    var latitude: Double?
    var longitude: Double?
    var text: String = ""
}

// MARK: Extendable
extension VoyageEvent {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.time == rhs.time &&
        lhs.location == rhs.location &&
        lhs.text == rhs.text
    }
    var location: Coordinate? {
        get {
            if let latitude,
               let longitude
            {
                return .init(latitude: latitude, longitude: longitude)
            }
            return nil
        }
        set {
            self.latitude = newValue?.latitude
            self.longitude = newValue?.longitude
        }
    }
    init(time: Date = .now, location: Coordinate?, text: String = "") {
        self.time = time
        self.text = text
        self.location = location
    }
    init(location: Coordinate?, between start: Date?, and end: Date?) {
        self.location = location
        self.text = ""
        let date = Date.now
        if let start {
            if let end {
                let timeToEnd = end.timeIntervalSince(start)
                self.time = start.addingTimeInterval(.random(in: 0..<timeToEnd))
            }
            else if date.withoutTime == start.withoutTime {
                self.time = date
            }
            else {
                let timeToEndOfDay = start.withoutTime.tomorrow.timeIntervalSince(start)
                self.time = start.addingTimeInterval(.random(in: 0..<timeToEndOfDay))
            }
        }
        else if let end {
            self.time = end.withoutTime.addingTimeInterval(.random(in: 0..<end.timeAsInterval))
        }
        else {
            self.time = date
        }
    }
}

// MARK: Preview
extension Array where Element == VoyageEvent {
    static func random(in range: ClosedRange<Date> = Date.now.allDay) -> Self {
        let situation = [0,0,0,0,0,1,1,2,3].randomElement()!
        switch situation {
        case 3: return fuelFilter(in: range)
        case 2: return lobsterBuoy(in: range)
        case 1: return wildlife(in: range)
        default: return []
        }
    }
    private static func fuelFilter(in range: ClosedRange<Date> = Date.now.allDay) -> Self {
        let timestamps = (range.lowerBound.timeIntervalSince1970)...(range.upperBound.timeIntervalSince1970)
        let startstamp = TimeInterval.random(in: timestamps)
        let duration = TimeInterval.random(in: 30.minute...2.hour)
        return [
            .init(
                time: .init(timeIntervalSince1970: startstamp),
                location: .init(latitude: 44.6749, longitude: -67.3522),
                text: "Emergency anchor - engine died"
            ),
            .init(
                time: .init(timeIntervalSince1970: startstamp + duration),
                location: .init(latitude: 44.6749, longitude: -67.3522),
                text: "Underway - fuel filters changed"
            )
        ]
    }
    private static func lobsterBuoy(in range: ClosedRange<Date> = Date.now.allDay) -> Self {
        let timestamps = (range.lowerBound.timeIntervalSince1970)...(range.upperBound.timeIntervalSince1970)
        let startstamp = TimeInterval.random(in: timestamps)
        let duration = TimeInterval.random(in: 30.minute...2.hour)
        return [
            .init(
                time: .init(timeIntervalSince1970: startstamp),
                location: .init(latitude: 44.6749, longitude: -67.3522),
                text: "Caught lobster buoy"
            ),
            .init(
                time: .init(timeIntervalSince1970: startstamp + duration),
                location: .init(latitude: 44.5100, longitude: -67.5678),
                text: "Underway"
            )
        ]
    }
    static func wildlife(in range: ClosedRange<Date> = Date.now.allDay) -> Self {
        let sightingCount = [1,1,1,1,1,1,1,1,2,2,2,2,3].randomElement()!
        return (0..<sightingCount).map { _ in
            .init(
                time: .init(timeIntervalSince1970: .random(in: (range.lowerBound.timeIntervalSince1970)...(range.upperBound.timeIntervalSince1970))),
                location: .init(latitude: 44.6713, longitude: -67.3602),
                text: wildlifeOptions.randomElement()!
            )
        }
    }
    private static var wildlifeOptions: [String] {
        [
            "Sighted seal",
            "Bald eagle",
            "Razorbill families"
        ]
    }
}
extension VoyageEvent {
    static var random: VoyageEvent {
        [VoyageEvent].random().randomElement() ?? [VoyageEvent].wildlife().first!
    }
}


// MARK: Codable
extension VoyageEvent {
    enum CodingKeys: CodingKey {
        case id, time, latitude, longitude, text
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        time = try container.decode(Date.self, forKey: .time)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        text = try container.decode(String.self, forKey: .text)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(time, forKey: .time)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encode(text, forKey: .text)
    }
}
