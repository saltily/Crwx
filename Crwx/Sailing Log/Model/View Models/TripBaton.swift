//
//  TripBaton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 5/7/25.
//

import Foundation
import CoreLocation
import FoundationSalt
import SwiftUI

/// A few fields from the previous trip that will help pre-populate fields on the next trip.
struct TripBaton {
    let odometer: Int?
    let fuel: FuelSounding?
    let location: LocationSnippet?
    let harbour: Harbour?
    let passengers: String
    let dinghy: DinghyOption
    /// When we anchored, that current depth minus that current tide
    let chartDepth: Double?
}
extension TripBaton {
    var isHome: Bool {
        guard let location else { return false }
        return location.distance(to: CLLocationCoordinate2D.Home).converted(to: .feet).value < 500
    }
}

extension Trip {
    var baton: TripBaton {
        .init(
            odometer: odometerEnd,
            fuel: fuelEnd,
            location: arrivalLocation,
            harbour: endHarbour,
            passengers: passengers,
            dinghy: dinghy,
            chartDepth: chartDepthEnd
        )
    }
}

extension EnvironmentValues {
    struct TripBatonKey: EnvironmentKey {
        static var defaultValue: TripBaton? {
            return nil
        }
    }
    var baton: TripBaton? {
        get { self[TripBatonKey.self] }
        set { self[TripBatonKey.self] = newValue }
    }
}

