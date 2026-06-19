//
//  MarineZoneSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/7/24.
//

import Foundation
import FoundationSalt
import WxSalt

struct MarineZoneSnippet: Codable, Equatable {
    let id: String
    let name: String
    let officialName: String
}


// MARK: Zero
extension MarineZoneSnippet {
    static var zero: MarineZoneSnippet {
        .init(id: "", name: "", officialName: "")
    }
    var isEmpty: Bool {
        id.isEmpty && name.isEmpty && officialName.isEmpty
    }
}



// MARK: Extended
extension MarineZoneSnippet {
    var resolved: MarineZone? {
        MarineZone.active.first(where: {
            $0.id == self.id
        })
    }
}

// MARK: Make from zone
extension MarineZone {
    var snippet: MarineZoneSnippet {
        .init(id: self.id, name: self.name, officialName: self.officialName)
    }
}


// MARK: Preview
extension MarineZoneSnippet {
    static var random: MarineZoneSnippet {
        MarineZone.active.randomElement()!.snippet
    }
}


// MARK: Codable
extension MarineZoneSnippet {
    enum CodingKeys: CodingKey {
        case id, name, officialName
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        officialName = try container.decode(String.self, forKey: .officialName)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(officialName, forKey: .officialName)
    }
}
