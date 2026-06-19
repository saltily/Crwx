//
//  MarineBuoySnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/7/24.
//

import Foundation
import WxSalt

struct MarineBuoySnippet: Codable, Equatable {
    let id: String
    let name: String
    let subname: String
    let officialName: String
    let latitude: Double
    let longitude: Double
}

extension MarineBuoySnippet {
    var resolved: MarineBuoy? {
        MarineBuoy.all.first(where: {
            $0.id == self.id
        })
    }
}


// MARK: Make from buoy
extension MarineBuoy {
    var snippet: MarineBuoySnippet {
        .init(id: self.id, name: self.name, subname: self.subname, officialName: self.officialName, latitude: self.latitude, longitude: self.longitude)
    }
}


// MARK: Previews
extension MarineBuoySnippet {
    static var random: MarineBuoySnippet {
        MarineBuoy.offshore.randomElement()!.snippet
    }
}

// MARK: Codable
extension MarineBuoySnippet {
    enum CodingKeys: CodingKey {
        case id, name, subname, officialName, latitude, longitude
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        subname = try container.decode(String.self, forKey: .subname)
        officialName = try container.decode(String.self, forKey: .officialName)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(subname, forKey: .subname)
        try container.encode(officialName, forKey: .officialName)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
