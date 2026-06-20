//
//  TideStationSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/7/24.
//

import Foundation
import WxSalt
internal import _LocationEssentials

struct TideStationSnippet: Codable, Equatable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
}

extension TideStationSnippet {
    var resolved: TideStation? {
        TideStation.all.first(where: {
            $0.id == self.id
        })
    }
}


// MARK: Read from tide station
extension TideStation {
    var snippet: TideStationSnippet {
        .init(id: self.id, name: self.name, latitude: self.location.coordinate.latitude, longitude: self.location.coordinate.longitude)
    }
}


// MARK: Preview
extension TideStationSnippet {
    static var random: TideStationSnippet {
        TideStation.all.randomElement()!.snippet
    }
}


// MARK: Codable
extension TideStationSnippet {
    enum CodingKeys: CodingKey {
        case id, name, latitude, longitude
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
