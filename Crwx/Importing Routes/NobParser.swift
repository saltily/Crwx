//
//  NobParser.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import Foundation
import SWXMLHash
import FoundationSalt

// MARK: Init
struct NobParser {
    let url: URL?
    let created: String?
    let size: Int64
    let markTrees: [XMLIndexer]
    let routeTrees: [XMLIndexer]
    let dateFormatter: ISO8601DateFormatter
    init?(url: URL) throws {
        self.init(data: try Data(contentsOf: url), url: url)
    }
    init?(data: Data, url: URL? = nil) {
        self.url = url
        let xml = XMLHash.parse(data)
        guard xml["NavObjectCollection"].all.count == 1 else { return nil }
        created = xml["NavObjectCollection"].element?[attribute: "created"]?.text
        size = Int64(data.count)
        markTrees = xml["NavObjectCollection"]["Mark"].all
        routeTrees = xml["NavObjectCollection"]["Route"].all
        self.dateFormatter = .init()
        dateFormatter.formatOptions.remove(.withDashSeparatorInDate)
        dateFormatter.formatOptions.remove(.withColonSeparatorInTime)
    }
}


// MARK: Waypoints
extension NobParser {
    /// The returned waypoint has not been inserted into a context yet, and it doesn't watch for deduplication
    func waypoint(at i: Int) throws -> Waypoint {
        let indexer = markTrees[i]
        // created
        guard let createdString = indexer[attribute: "created"]?.text
        else { throw ParseError.MissingRequiredProperty }
        guard let created = dateFormatter.date(from: createdString)
        else { throw ParseError.InvalidDate }
        // id
        guard let idString = indexer[attribute: "id"]?.text
        else { throw ParseError.MissingRequiredProperty }
        guard let id = UUID(uuidString: idString.trimmingCharacters(in: .punctuationCharacters))
        else { throw ParseError.InvalidUUID }
        // lat and long
        guard let position = indexer["Position"].element?.text
        else { throw ParseError.MissingRequiredProperty }
        let numbers = position.doubles // should be four
        guard numbers.count == 2
        else { throw ParseError.InvalidCoordinate }
        var latitude = numbers[0]
        var longitude = numbers[1]
        latitude = position.contains("S") ? latitude.inversed : latitude
        longitude = position.contains("W") ? longitude.inversed : longitude
        return Waypoint(
            id: id,
            source: "RosePoint",
            latitude: latitude,
            longitude: longitude,
            name: indexer["Name"].element?.text ?? "",
            _symbol: indexer["Icon"].element?.text,
            created: created,
            imported: .now,
            stamp: .stamp(latitude: latitude, longitude: longitude)
        )
    }
}


// MARK: Routes
extension NobParser {
    func route(at i: Int) throws -> Route {
        let indexer = routeTrees[i]
        // created
        guard let createdString = indexer[attribute: "created"]?.text
        else { throw ParseError.MissingRequiredProperty }
        guard let created = dateFormatter.date(from: createdString)
        else { throw ParseError.InvalidDate }
        // id
        guard let idString = indexer[attribute: "id"]?.text
        else { throw ParseError.MissingRequiredProperty }
        guard let id = UUID(uuidString: idString.trimmingCharacters(in: .punctuationCharacters))
        else { throw ParseError.InvalidUUID }
        // marks
        guard let marksString = indexer["Marks"].element?.text
        else { throw ParseError.MissingRequiredProperty }
        let marks: [UUID] = try marksString.components(separatedBy: "}").compactMap {
            let string = String($0).trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
            if string.isEmpty { return nil }
            guard let id = UUID(uuidString: String($0).trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters)))
            else { throw ParseError.InvalidUUID }
            return id
        }
        // length
        guard let totalLength = indexer["TotalLength"].element?.text
        else { throw ParseError.MissingRequiredProperty }
        guard let length = Double(totalLength.trimmingRight(in: .init(charactersIn: " NM")))
        else { throw ParseError.InvalidDistance }
        return Route(
            id: id,
            name: indexer["Name"].element?.text ?? "",
            _waypoints: marks.encoded,
            length: length,
            created: created,
            imported: .now,
            endpointNames: "",
            endpointIds: "",
            endpointStamps: ""
        )
    }
}

// MARK: Tracker Setup
extension NobParser {
    var count: Int {
        markTrees.count + routeTrees.count
    }
}
extension [NobParser] {
    var totalCount: Int {
        self.reduce(0) { partialResult, parser in
            partialResult + parser.count
        }
    }
}


// MARK: Debug
extension NobParser: CustomDebugStringConvertible {
    var debugDescription: String {
"""
NobParser(
    file: \(url?.lastPathComponent ?? "")
    size: \(size.formatted(.byteCount(style: .file)))
    created: \(created ?? "")
    marks: \(markTrees.count)
    routes: \(routeTrees.count)
)
"""
    }
}
