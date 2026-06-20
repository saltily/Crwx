//
//  Cruise.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/7/25.
//

import Foundation
import FoundationUI
import FoundationSalt
import SwiftData

typealias Cruise = CurrentSchema.Cruise

/// ```swift
/// var id: UUID = UUID()
/// var _anchorages: Data? // [AnchorageSnippet]
/// var _start: Date = Date.now // Day
/// var forecastFetched: Date?
/// var _colours: String = "red" // ColorPattern.Family
/// var _weather: Data? // CruiseWeather
/// var trips: [Trip]? = []
/// ```
extension Cruise {
    var anchorages: [CruiseViewModel.AnchorageSnippet] {
        get { .init(decoding: _anchorages) ?? [] }
        set { _anchorages = newValue.encoded }
    }
    var legs: [CruiseViewModel.LegSnippet] {
        get { .init(decoding: _legs) ?? [] }
        set { _legs = newValue.encoded }
    }
    var routes: [RouteSnippet] {
        legs.map { $0.route }
    }
    var start: Day {
        get { _start.day }
        set { _start = newValue.start }
    }
    var colours: ColorPattern.Family {
        get { .init(rawValue: _colours) ?? .red }
        set { _colours = newValue.rawValue }
    }
    var weather: CruiseWeather {
        get { .init(decoding: _weather) ?? .init() }
        set { _weather = newValue.encoded }
    }
    var isLocked: Bool {
        trips?.nilIfEmpty != nil
    }
}


// MARK: Filter
extension Cruise {
    static func find(_ id: UUID?, in context: ModelContext) -> Cruise? {
        guard let id else { return nil }
        return try? context.fetchOne(#Predicate {
            $0.id == id
        })
    }
    static func last(in context: ModelContext) -> Cruise? {
        let d = FetchDescriptor<Cruise>(sortBy: [.init(\._start, order: .reverse)])
        return try? context.fetchOne(d)
    }
}


// MARK: Web Sharing
extension Cruise: Encodable {
    enum CodingKeys: CodingKey {
        case id, uuid, start, colours, trips
    }
    /// This is specifically to send json to website for sharing
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .uuid)
        try container.encodeIfPresent(webId, forKey: .id)
        try container.encode(start.start.reader().mysql_date, forKey: .start)
        try container.encode(colours.rawValue, forKey: .colours)
        try container.encode(trips ?? [], forKey: .trips)
    }
}
extension Cruise: WebShareable {
    func share(_ context: ModelContext) async throws -> URL {
        if let id = self.webId {
            logger.trace("Previously uploaded")
            return URL(string: "https://www.saltily.com/blouse/cruise?id=\(id)")!
        }
        else {
            let url = URL(string: "https://www.saltily.com/blouse/upload-cruise")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = self.json
            let (data, _) = try await URLSession.shared.data(for: request)
            if let string = String(data: data, encoding: .utf8) {
                logger.trace("\(string)")
            }
            guard let result = try WebShareResult(json: data)
            else { throw WebShareResult.E.InvalidResponse }
            guard let id = result.id
            else { throw WebShareResult.E.InvalidResponse }
            self.webId = id
            for (uuid, id) in (result.trip_ids ?? [:]) {
                if let trip = Trip.find(.init(uuidString: uuid), in: context) {
                    assert(trip.webId == nil)
                    trip.webId = id
                }
            }
            for (uuid, id) in (result.harbour_ids ?? [:]) {
                if let harbour = Harbour.find(.init(uuidString: uuid), in: context) {
                    assert(harbour.webId == nil)
                    harbour.webId = id
                }
            }
            try context.save()
            if let error = result.error {
                throw WebShareResult.E.Online(error)
            }
            return URL(string: "https://www.saltily.com/blouse/cruise?id=\(id)")!
        }
    }
}
