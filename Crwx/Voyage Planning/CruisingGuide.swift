//
//  CruisingGuide.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/23/25.
//

import Foundation

struct CruisingGuide: Codable, Equatable {
    var year: Int = 2024
    var summary: String = ""
    var approaches: String = ""
    var anchoring: String = ""
    var gettingAshore: String = ""
    var services: String = ""
    var activities: String = ""
    var charts: String = ""
    var cached: Data?
}

// MARK: Searching
extension CruisingGuide {
    func localizedStandardContains(_ string: String) -> Bool {
        [summary, approaches, anchoring, gettingAshore, services, activities].joined().localizedStandardContains(string)
    }
    var isEmpty: Bool {
        [summary, approaches, anchoring, gettingAshore, services, activities].compactMap {
            $0.nilIfEmpty
        }.isEmpty
    }
}

// MARK: Codable
extension CruisingGuide {
    enum CodingKeys: CodingKey {
        case year, summary, approaches, anchoring, gettingAshore, services, activities, cached, charts
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        year = try container.decode(Int.self, forKey: .year)
        summary = try container.decode(String.self, forKey: .summary)
        approaches = try container.decode(String.self, forKey: .approaches)
        anchoring = try container.decode(String.self, forKey: .anchoring)
        gettingAshore = try container.decode(String.self, forKey: .gettingAshore)
        services = try container.decode(String.self, forKey: .services)
        activities = try container.decode(String.self, forKey: .activities)
        cached = try container.decodeIfPresent(Data.self, forKey: .cached)
        charts = try container.decodeIfPresent(String.self, forKey: .charts) ?? ""
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(year, forKey: .year)
        try container.encode(summary, forKey: .summary)
        try container.encode(approaches, forKey: .approaches)
        try container.encode(anchoring, forKey: .anchoring)
        try container.encode(gettingAshore, forKey: .gettingAshore)
        try container.encode(services, forKey: .services)
        try container.encode(activities, forKey: .activities)
        try container.encodeIfPresent(cached, forKey: .cached)
        try container.encode(charts, forKey: .charts)
    }
}
