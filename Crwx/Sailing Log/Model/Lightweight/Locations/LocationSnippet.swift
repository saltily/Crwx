//
//  LocationSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import CoreLocation
import FoundationSalt
import SwiftData

struct LocationSnippet: nonisolated Codable, Equatable, Hashable {
    var name: String?
    var latitude: Double
    var longitude: Double
}

// MARK: Zero
extension LocationSnippet {
    static var zero: LocationSnippet {
        .init(name: nil, latitude: 0, longitude: 0)
    }
    var isEmpty: Bool {
        name == nil && self.latitude == 0 && self.longitude == 0
    }
}

// MARK: Extended
extension LocationSnippet {
    init(placemark: CLPlacemark?, coordinate: CLLocationCoordinate2D) {
        self.name = placemark?.locality ?? placemark?.ocean ?? ""
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    init(_ point: any Mappable) {
        self.name = point.label ?? ""
        self.latitude = point.coordinate.latitude
        self.longitude = point.coordinate.longitude
    }
    init(name: String, point: any Mappable) {
        self.name = name
        self.latitude = point.coordinate.latitude
        self.longitude = point.coordinate.longitude
    }
    init?(_ point: (any Mappable)?, in container: ModelContainer) async throws {
        guard let point else { return nil }
        self.name = try await point.lookupName(in: container) ?? ""
        self.latitude = point.coordinate.latitude
        self.longitude = point.coordinate.longitude
    }
}
extension LocationSnippet: Mappable {
    var label: String? {
        name
    }    
    var coordinate: CLLocationCoordinate2D {
        get {
            .init(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    var formattedAddress: String? { nil }
    static func make(from point: any FoundationSalt.Mappable) -> LocationSnippet? {
        self.init(point)
    }
}


// MARK: Preview
extension LocationSnippet {
    static var random: LocationSnippet {
        self.commonLocations.randomElement()!
    }
    static var commonLocations: [LocationSnippet] {
        [
            .init(name: "Home", latitude: 44.7005, longitude: -67.3927),
            .init(name: "Cross Island", latitude: 44.6149, longitude: -67.2840),
            .init(name: "Bucks Harbor", latitude: 44.6384, longitude: -67.3727),
            .init(name: "Roque Island", latitude: 44.5733, longitude: -67.5199),
            .init(name: "Mistake Island", latitude: 44.4750, longitude: -67.5398)
        ]
    }
}
extension CLLocation {
    static func randomOnCoastOfMaine() -> CLLocation {
        let latitude: Double = .random(in: 43.0515...44.9791)
        let longitude: Double = .random(in: -70.6725...(-66.9439))
        return .init(latitude: latitude, longitude: longitude)
    }
}


// MARK: Fetch Name
extension LocationSnippet {
    /// Brings a name into this snippet.  If you provide the model container, it will try to use harbour names, otherwise it will just reverse geocode.
    mutating func fetchName(in container: ModelContainer? = nil) async throws {
        if let container {
            self.name = try await self.lookupName(in: container) ?? ""
        }
        else {
            self.name = await coordinate.name
        }
    }
}
extension Mappable {
    /// Reverse geocode lookup the name.
    ///
    /// The places where this is used are places where we want the geocode name and not a harbour name.  If you might want a harbour name, use ``lookupName(in:)`` instead.
    var name: String {
        get async {
            do {
                return try await Retry.do(3) {
                    let placemark = try await CLGeocoder().reverseGeocodeLocation(clLocation).first
                    return placemark?.locality ?? placemark?.ocean ?? ""
                }
            } catch {
                return ""
            }
        }
    }
}

// MARK: Codable
extension LocationSnippet {
    enum CodingKeys: CodingKey {
        case name, latitude, longitude
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
