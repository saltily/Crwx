//
//  RouteEditor+MapContent.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/18/25.
//

import SwiftUI
import MapKit
import FoundationUI

extension RouteEditor {
    struct MapBody: MapContent {
        @Bindable var route: RouteMaker
        let region: MKCoordinateRegion
        var body: some MapContent {
            ForEach(route.legs.sorted()) { leg in
                Polyline(leg.points, tint: .gray, thickness: 1)
            }
            if let existingRoute = route.existingRoute {
                Polyline(existingRoute.points, tint: .accentColor, thickness: 1)
            }
            ForEach(route.allWaypoints) { wp in
                if wp.display(in: region) {
                    MapDot(snippet: wp)
                }
            }
            if let start = route.start {
                MapMarker(start)
            }
            if let end = route.end {
                MapMarker(end, defaultTint: .red)
            }
            if route.state == .addEnd,
               let start = route.points.first
            {
                MapPolyline([start, region.center])
                    .stroke(.black, style: .init(lineWidth: 1, dash: [3,2]))
            }
            let linePoints = route.state == .dropOrDeselect ? route.draggingPoints(in: region) : route.points.map { $0.coordinate }
            if linePoints.count > 1 {
                Polyline(linePoints)
            }
            ForEach(route.newPoints) { wp in
                TrackDot(wp, tint: .red)
            }
            if let hovered = route.pickup(in: region) {
                if hovered.isMajor {
                    MapDot(hovered, tint: .accentColor)
                } else {
                    TrackDot(hovered, tint: .accentColor)
                }
            }
        }
    }
}
