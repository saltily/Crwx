//
//  RouteMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import MapKit
import FoundationUI

struct RouteMap: View {
    let waypointIds: [UUID]
    @Environment(\.modelContext) private var context
    var body: some View {
        let waypoints = (try? Waypoint.mapping(waypointIds, in: context)) ?? []
        Map {
            ForEach(waypoints) { wp in
                Marker(wp.name, coordinate: wp.coordinate)
            }
            Polyline(waypoints, thickness: 5)
        }
    }
}
