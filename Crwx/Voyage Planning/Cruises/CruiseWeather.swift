//
//  CruiseWeather.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import Foundation
import FoundationSalt
import WxSalt

/// Part of the basic idea is that this is codable to store marine weather and not lose it as forecasts cycle forward.
/// Every time this is updated it only overwrites if there is a newer version of the forecast for the exact time, else it adds them.  Then when you ask for day or night it grabs the earliest or latest.  We might want to update that logic, which will be fine so long as the data is all kept.
/// ```swift
/// let anchorageWinds: [WindSnippet] = weather[zone, day]?.night ?? []
/// let wx = try await forecasts.marineWeather(for: zone)
/// try weather.update(zone: zone, wx: wx)
/// _weather = weather.encoded
/// let weather = .init(decoding: _weather)
/// ```
struct CruiseWeather: Codable {
    subscript(zone: MarineZone, day: Day) -> Winds? {
        contents[zone]?.contents[day]
    }
    mutating func update(zone: MarineZone, wx: MarineZoneWxForecast) throws {
        var block = contents[zone] ?? .init()
        try block.update(wx: wx, zone: zone)
        contents[zone] = block
    }
    mutating func update(zone: MarineZone, snippets: [ForecastSnippet]) throws {
        var block = contents[zone] ?? .init()
        try block.update(snippets: snippets, zone: zone)
        contents[zone] = block
    }
    private var contents: [MarineZone: Block] = [:]
}

extension CruiseWeather {
    struct Block: Codable {
        var contents: [Day: Winds] = [:]
        mutating func update(wx: MarineZoneWxForecast, zone: MarineZone) throws {
            for (day, wx) in wx.groupedByDay() {
                if !wx.isEmpty {
                    if var winds = contents[day] {
                        winds.update(wx: wx, zone: zone)
                        contents[day] = winds
                    } else {
                        let winds = try Winds(wx: wx, zone: zone)
                        contents[day] = winds
                    }
                }
            }
        }
        mutating func update(snippets: [ForecastSnippet], zone: MarineZone) throws {
            for group in snippets.grouped(by: \.date.day) {
                if !group.isEmpty {
                    if var winds = contents[group.id] {
                        winds.update(snippets: group.contents, zone: zone)
                        contents[group.id] = winds
                    } else {
                        let winds = try Winds(snippets: group.contents, zone: zone)
                        contents[group.id] = winds
                    }
                }
            }
        }
    }
}

extension CruiseWeather {
    struct Winds: Codable {
        fileprivate init(wx: [MarineZoneWeather], zone: MarineZone) throws {
            guard !wx.isEmpty else { throw E.NoWeather }
            id = wx[0].date.day
            snippets = wx.map {
                .init(zone: zone, wx: $0, date: $0.date)
            }.sorted(by: \.date)
        }
        fileprivate init(snippets: [ForecastSnippet], zone: MarineZone) throws {
            guard !snippets.isEmpty else { throw E.NoWeather }
            id = snippets[0].date.day
            self.snippets = snippets
        }
        fileprivate mutating func update(wx: [MarineZoneWeather], zone: MarineZone) {
            // be sure to only add, not remove
            for chunk in wx {
                if let i = snippets.firstIndex(where: {
                    $0.date == chunk.date
                }) {
                    snippets[i] = .init(zone: zone, wx: chunk, date: chunk.date)
                } else {
                    snippets.append(.init(zone: zone, wx: chunk, date: chunk.date))
                }
            }
            snippets = snippets.sorted(by: \.date)
        }
        fileprivate mutating func update(snippets: [ForecastSnippet], zone: MarineZone) {
            self.snippets = snippets
        }
        private let id: Day
        private var snippets: [ForecastSnippet]
        var day: [WindSnippet] {
            snippets.first?.winds ?? []
        }
        var night: [WindSnippet] {
            snippets.last?.winds ?? []
        }
    }
}

extension CruiseWeather {
    enum E: Error {
        case NoWeather
    }
}
