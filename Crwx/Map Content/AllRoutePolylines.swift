//
//  AllRoutePolylines.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/12/25.
//

import SwiftUI
import MapKit
import FoundationUI

struct AllRoutePolylines: MapContent {
    let routes: [Route]
    let colours: ColorPattern
    @Environment(\.modelContext) private var context
    var body: some MapContent {
        ForEach(0..<routes.count, id: \.self) { i in
            let route = routes[i]
            let waypoints = try? route.waypoints(in: context)
            Polyline(waypoints ?? [], tint: colours[i])
        }
        ForEach(hubWaypoints) { wp in
            MapDot(wp, tint: .green)
        }
    }
    private var hubWaypoints: [Waypoint] {
        routes.allWaypoints(in: context).filter {
            $0.isHub
//            $0.symbol == nil &&
//            !$0.name.isEmpty
        }
    }
}
