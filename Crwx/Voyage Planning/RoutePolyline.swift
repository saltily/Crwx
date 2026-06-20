//
//  RoutePolyline.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/8/25.
//

import SwiftUI
import MapKit
import FoundationUI
import FoundationSalt

struct RoutePolyline: MapContent {
    let route: RouteSnippet
    var tint: Color = .red
    var thickness: CGFloat = 3.0
    var region: MKCoordinateRegion?
    var measuredFrom: (any Mappable)?
    var threshold: Double = 3.0
    var body: some MapContent {
        Polyline(route.points, tint: tint)
        if showMeasurements {
            let measured = route.measured(from: measuredFrom ?? route.points.last)
            ForEach(measured) { wp in
                TrackDot(wp)
            }
        }
    }
    private var showMeasurements: Bool {
        if let region {
            let samplePoint = region.center.projected(by: .init(value: threshold/2, unit: .nauticalMiles), bearing: .init(value: 90, unit: .degrees))
            return !region.contains(samplePoint)
        }
        return true
    }
}
