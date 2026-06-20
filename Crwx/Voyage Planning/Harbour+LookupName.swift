//
//  Harbour+LookupName.swift
//  Mewx
//
//  Created by Matthew Goacher on 4/4/25.
//

import Foundation
import FoundationSalt
import SwiftData
import CoreLocation

extension Mappable {
    /// Prefer name of closest harbour within a quarter mile, or reverse geocode online.
    func lookupName(in container: ModelContainer) async throws -> String? {
        if let nearestHarbour = Harbour.at(location: self, in: .init(container)) {
            return nearestHarbour.name
        }
//        return await self.name.nilIfEmpty
        return try await Retry.do(3) {
            let placemark = try await CLGeocoder().reverseGeocodeLocation(clLocation).first
            return placemark?.locality ?? placemark?.ocean
        }
    }
}
