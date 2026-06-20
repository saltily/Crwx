//
//  RouteEditor+MapBasket.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/18/25.
//

import Foundation
import FoundationUI
import MapKit
import SwiftUI
import CoreLocation

extension RouteEditor {
    static func draw(_ map: MapBasket, route: RouteMaker, region: MKCoordinateRegion) {
        for leg in route.legs {
            map.line(leg.points, .gray, thickness: 1)
        }
        if let existingRoute = route.existingRoute {
            map.line(existingRoute.points, .accentColor, thickness: 1)
        }
        for wp in route.allWaypoints {
            if wp.display(in: region) {
                map.dot(snippet: wp)
            }
        }
        if route.state == .addEnd,
           let start = route.points.first
        {
            map.line([start, region.center], .black, thickness: 1, dash: [3,2])
        }
        let linePoints = route.state == .dropOrDeselect ? route.draggingPoints(in: region) : route.points.map { $0.coordinate }
        if linePoints.count > 1 {
            map.line(linePoints)
        }
        for wp in route.newPoints {
            map.trackDot(wp, tint: .red)
        }
        if let hovered = route.pickup(in: region) {
            if hovered.isMajor {
                map.dot(hovered, tint: .accentColor)
            } else {
                map.trackDot(hovered, tint: .accentColor)
            }
        }
        if let start = route.start {
            map.marker(start)
        }
        if let end = route.end {
            map.marker(end, defaultTint: .red)
        }
    }
}
