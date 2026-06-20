//
//  BackupData.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import Foundation
import FoundationSalt
import SwiftData
import WxSalt

struct BackupData: Codable {
    let summary: String
    let locations: [LocationProfileViewModel]
    let trips: [TripViewModel]
}

extension BackupData {
    init(context: ModelContext) throws {
        try Task.checkCancellation()
        locations = try context.backup()
        try Task.checkCancellation()
        trips = try context.backup()
        summary = """
On \(Date.now.formatted(.dateTime)) we exported:
    \(locations.count) location(s),
    and \(trips.count.formatted(.number)) trip(s).
"""
    }
}

extension ModelContext {
    var isEmpty: Bool {
        do {
            return try self.fetchCount(LocationProfile.self) == 3 &&
            self.fetchCount(Trip.self) == 0
        } catch {
            fatalError()
        }
    }
}
