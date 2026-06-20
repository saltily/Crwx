//
//  CurrentSpeedSymbol.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/8/25.
//

import SwiftUI
import MapKit
import CoreLocation
import FoundationUI
import FoundationSalt

struct CurrentSpeedSymbol: MapContent {
    let coordinate: CLLocationCoordinate2D
    let speed: Double?
    let heading: Measurement<UnitAngle>?
    var body: some MapContent {
        let tint: Color = .mint
        if let speed,
           let heading
        {
            Annotation("", coordinate: coordinate, anchor: .center) {
                Image(systemName: "location.north.fill")
                    .rotationEffect(.degrees(heading.converted(to: .degrees).value))
                    .foregroundStyle(tint)
                    .shadow(color: .black.opacity(0.8), radius: 3)
            }
            let projected = coordinate.projected(by: .init(value: speed/4, unit: .nauticalMiles), bearing: heading)
            Polyline([coordinate, projected], tint: tint, thickness: 2)
        } else {
            MapDot(coordinate, tint: tint)
        }
    }
}
extension MapBasket {
    func currentSpeed(coordinate: CLLocationCoordinate2D, speed: Double?, heading: Measurement<UnitAngle>?) {
        let tint: Color = .pink
        self.dot(coordinate, tint: tint)
        if let speed,
           let heading
        {
            let projected = coordinate.projected(by: .init(value: speed/4, unit: .nauticalMiles), bearing: heading)
            self.line([coordinate, projected], tint, thickness: 2)
        }
    }
}
