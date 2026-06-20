//
//  CoastalForecasts.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/27/25.
//

import Foundation
import FoundationSalt
import Network
import WeatherKit
import os
import WxSalt

/// A background cache so that when putting together anchoring estimates, it doesn't need to keep refetching stuff that comes from a common weather source.
/// Most likely to fetch and cache marine zone forecasts and tide tables.  I feel like determining the swell direction will be a function of looking at previous wind speeds and directions.  The swell is almost always out of the south, but sometimes also in other directions and bigger or smaller on the coast per the wind direction.
final actor CoastalForecasts {
    let logger: Logger? = nil // Logger(subsystem: "com.saltily.Mewx", category: "CoastalForecasts")
    /// Setup to listen for when the device is offline so I can save waiting for connections to fail and return cached weather instead
    init() {
//        marineWxCache = try? .init()
//        tidesWxCache = try? .init()
//        let queue = DispatchQueue(label: "ForecastsConnectionMonitor")
//        self.queue = queue
//        monitor = .init()
//        monitor.pathUpdateHandler = { path in
//            Task {
//                await self.set(offline: path.status != .satisfied)
//            }
//            self.logger?.info("We heard the network path changed to \(describing(path))")
//        }
//        monitor.start(queue: queue)
    }
//    private let queue: DispatchQueue
//    private let monitor: NWPathMonitor
//    func set(offline: Bool) async {
//        isOffline = offline
//    }
//    private var isOffline: Bool = false
    
    // MARK: Marine Weather
//    private let marineWxCache: MarineWeatherCache?
    func forecast(for zone: MarineZone, during range: ClosedRange<Date>) async throws -> [ForecastSnippet] {
        guard let wx = await marineWeather(for: zone)
        else { throw E.NoMarineCache }
        var forecast = wx.forecast.filter {
            // figure out which forecast blocks (sometimes 12 hours, sometimes 24 hours) touch this range
            // if the weather starts after the range, it doesn't apply
            $0.date <= range.upperBound
        }
        // only want to keep the latest that starts before
        if let i = forecast.lastIndex(where: { $0.date < range.lowerBound } ) {
            forecast.removeFirst(i)
        }
        guard let last = forecast.last,
              range.lowerBound.timeIntervalSince(last.date) < 24.hour
        else { throw E.StaleMarineCache }
        return forecast.map {
            .init(zone: zone, wx: $0, date: $0.date)
        }
    }
    func marineWeather(for zone: MarineZone) async -> MarineZoneWxForecast? {
        try? await MarineZoneWxService().weather(for: zone)
//        if isOffline {
//            logger?.trace("We think we are offline.")
//            return marineWxCache?[zone]
//        }
//        do {
//            let wx = try await MarineZoneWxService().weather(for: zone)
//            marineWxCache?[zone] = wx
//            return wx
//        } catch {
//            logger?.warning("We got an error on marine weather: \(error)")
//            return marineWxCache?[zone]
//        }
    }
    func extendedMarineWeather(for zone: MarineZone, start: Day) async throws -> [ForecastSnippet] {
        // Get the marine weather either which way
        var chunks: [ForecastSnippet] = await marineWeather(for: zone)?.forecast.map {
            ForecastSnippet(zone: zone, wx: $0, date: $0.date)
        } ?? []
        // What's our hope?
        let end = start.adding(days: 10)
        // We know that the marine weather won't cover this
        // If any of it's in the future, let's just get all of the weather forecast
        if end.end > .now.adding(days: 4) {
            mergeMissingChunks(from: try await appleZoneForecast(for: zone), into: &chunks)
        }
        if start < .today {
            mergeMissingChunks(from: try await appleZoneHistory(for: zone, range: start.start...(.today)), into: &chunks)
        }
        return chunks.sorted(by: \.date)
    }
    /// This is not cached and attempts to get 12-hour wind forecasts similar to marine zone.
    /// For use with cruise planning outside of the 5-day zone forecast window.
    func appleZoneForecast(for zone: MarineZone) async throws -> [ForecastSnippet] {
        let wx = try await WeatherService().weather(for: zone.clLocation)
        return parseAppleIntoHalfdays(hours: wx.hourlyForecast, zone: zone)
    }
    /// This is not cached and attempts to get 12-hour wind forecasts similar to marine zone.
    /// For use with cruise planning outside of the 5-day zone forecast window.
    func appleZoneHistory(for zone: MarineZone, range: ClosedRange<Date>) async throws -> [ForecastSnippet] {
        // they'll only let you do 10 days at a time
        let start = range.lowerBound
        let end = min(range.upperBound, start.adding(days: 10))
        let wx = try await AppleHistoryWxService().weather(for: zone.clLocation, from: start, to: end)
        return parseAppleIntoHalfdays(hours: wx.hourly, zone: zone)
    }
    private func parseAppleIntoHalfdays(hours: Forecast<HourWeather>, zone: MarineZone) -> [ForecastSnippet] {
        hours.grouped(by: \.date.half).map {
            .init(hours: $0.contents, zone: zone, date: $0.id.start)
        }
    }
    private func mergeMissingChunks(from new: [ForecastSnippet], into existing: inout [ForecastSnippet]) {
        // only accept weather that we don't already have
        let keyed = existing.reduce(into: [HalfDay: ForecastSnippet]()) { partialResult, snippet in
            partialResult[snippet.date.half] = snippet
        }
        for snippet in new {
            let half = snippet.date.half
            if keyed[half] == nil {
                existing.append(snippet)
            }
        }
    }
    
    // MARK: Tides
//    private let tidesWxCache: TidesCache?
    func lowestHeightOfTide(at station: TideStation, during range: ClosedRange<Date>) async throws -> Double {
        let tides = try await tides(at: station, covering: range.expanding(1.hour))
        var depths = tides.predictions(for: range).map { $0.height.converted(to: .feet).value }
        guard let first = tides.look(at: range.lowerBound),
              let last = tides.look(at: range.upperBound)
        else { throw E.OutOfBounds }
        depths.append(first.height.converted(to: .feet).value)
        depths.append(last.height.converted(to: .feet).value)
        guard let min = depths.min()
        else { throw E.OutOfBounds }
        return min
    }
    func highestHeightOfTide(at station: TideStation, during range: ClosedRange<Date>) async throws -> Double {
        let tides = try await tides(at: station, covering: range.expanding(1.hour))
        var depths = tides.predictions(for: range).map { $0.height.converted(to: .feet).value }
        guard let first = tides.look(at: range.lowerBound),
              let last = tides.look(at: range.upperBound)
        else { throw E.OutOfBounds }
        depths.append(first.height.converted(to: .feet).value)
        depths.append(last.height.converted(to: .feet).value)
        guard let max = depths.max()
        else { throw E.OutOfBounds }
        return max
    }
    func tide(for station: TideStation, at date: Date) async throws -> TideSnapshot {
        let tides = try await tides(at: station, covering: date.addingTimeInterval(-1.hour)...date.addingTimeInterval(1.hour))
        guard let snapshot = tides.look(at: date)
        else { throw E.OutOfBounds }
        return snapshot
    }
    func predictions(for station: TideStation, during: ClosedRange<Date>) async throws -> [TidePredictionSnippet] {
        let tides = try await tides(at: station, covering: during)
        let s = station.snippet
        return tides.predictions(for: during).map {
            $0.snippet(station: s)
        }
    }
    func plots(for station: TideStation, during: ClosedRange<Date>) async throws -> [TidePrediction] {
        let tides = try await tides(at: station, covering: during)
        return tides.predictions(for: during.expanding(1.day))
    }
    private func tides(at station: TideStation, covering range: ClosedRange<Date>) async throws -> Tides {
        try await TideWxService().weather(for: station, from: range.lowerBound.subtractingTimeInterval(7.day), to: range.upperBound.addingTimeInterval(7.day))
//        let cached = tidesWxCache?[station]
//        if let cached {
//            if cached.dates.contains(range) {
//                return cached
//            }
//            if isOffline { throw E.StaleTideCache }
//        }
//        if isOffline {
//            logger?.trace("We think we are offline.")
//            throw E.NoTideCache
//        }
//        do {
//            let tides = try await TideWxService().weather(for: station, from: range.lowerBound.subtractingTimeInterval(7.day), to: range.upperBound.addingTimeInterval(7.day))
//            tidesWxCache?[station] = tides
//            return tides
//        } catch {
//            logger?.warning("We got an error on the tides: \(error)")
//            throw cached == nil ? E.NoTideCache : E.StaleTideCache
//        }
    }
    enum E: Error {
        case OutOfBounds
        case NoMarineCache
        case StaleMarineCache
        case NoTideCache
        case StaleTideCache
    }
}


// MARK: Marine Cache
//final class MarineWeatherCache {
//    init() throws {
//        let bundle = Bundle.main.bundleIdentifier ?? "com.saltily.Mewx"
//        guard let d = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appending(path: "\(bundle)/wx", directoryHint: .isDirectory)
//        else { throw E.NoCacheDirectory }
//        try FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
//        cacheURL = d.appendingPathComponent("MarineZoneForecasts", conformingTo: .json)
//    }
//    private let cacheURL: URL
//    
//    // go straight to and from the disk in case multiple of these
//    subscript(zone: MarineZone) -> MarineZoneWxForecast? {
//        get { (try? read())?[zone.id] }
//        set {
//            Task {
//                do {
//                    var contents = try read()
//                    contents[zone.id] = newValue
//                    try await save(contents: contents)
//                } catch {
//                    logger.warning("Couldn't save marine zone cache")
//                }
//            }
//        }
//    }
//    
//    private func read() throws -> [String: MarineZoneWxForecast] {
//        if let data = try? Data(contentsOf: cacheURL) {
//            return (try? .init(json: data)) ?? [:]
//        } else {
//            return [:]
//        }
//    }
//    private func save(contents: [String: MarineZoneWxForecast]) async throws {
//        guard let data = contents.json
//        else { throw E.NoEncode }
//        try data.write(to: cacheURL)
//    }
//    
//    enum E: Error {
//        case NoCacheDirectory
//        case NoEncode
//    }
//}

// MARK: Tides Cache
//final class TidesCache {
//    init() throws {
//        let bundle = Bundle.main.bundleIdentifier ?? "com.saltily.Mewx"
//        guard let d = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appending(path: "\(bundle)/wx", directoryHint: .isDirectory)
//        else { throw E.NoCacheDirectory }
//        try FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
//        cacheURL = d.appendingPathComponent("TideTables", conformingTo: .json)
//    }
//    private let cacheURL: URL
//    
//    // go straight to and from the disk in case multiple of these
//    subscript(station: TideStation) -> Tides? {
//        get { (try? read())?[station.id] }
//        set {
//            Task {
//                do {
//                    var contents = try read()
//                    contents[station.id] = newValue
//                    try await save(contents: contents)
//                } catch {
//                    logger.warning("Couldn't save tides cache")
//                }
//            }
//        }
//    }
//    
//    private func read() throws -> [Int: Tides] {
//        if let data = try? Data(contentsOf: cacheURL) {
//            return (try? .init(json: data)) ?? [:]
//        } else {
//            return [:]
//        }
//    }
//    private func save(contents: [Int: Tides]) async throws {
//        guard let data = contents.json
//        else { throw E.NoEncode }
//        try data.write(to: cacheURL)
//    }
//    
//    enum E: Error {
//        case NoCacheDirectory
//        case NoEncode
//    }
//}
