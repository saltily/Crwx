//
//  WebShareable.swift
//  Mewx
//
//  Created by Matthew Goacher on 8/29/25.
//

import Foundation
import SwiftData

protocol WebShareable {
    func share(_ context: ModelContext) async throws -> URL
}
struct WebShareResult: Codable {
    let id: Int?
    let success: String?
    let startHarbour_id: Int?
    let endHarbour_id: Int?
    let trip_ids: [String: Int]?
    let harbour_ids: [String: Int]?
    let error: String?
    enum E: Error {
        case InvalidResponse
        case Online(String)
    }
}
