//
//  WaypointsMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import MapKit

struct WaypointsMap: View {
    let waypoints: [Waypoint]
    var body: some View {
        Map {
            ForEach(waypoints) { wp in
                Marker(wp.name, coordinate: wp.coordinate)
            }
        }
    }
}
