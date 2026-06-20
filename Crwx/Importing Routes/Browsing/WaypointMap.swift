//
//  WaypointMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import MapKit

struct WaypointMap: View {
    @Bindable var waypoint: Waypoint
    @State private var position: MapCameraPosition = .automatic
    var body: some View {
        Map(position: $position) {
            Marker(waypoint.name, coordinate: waypoint.coordinate)
        }
        .onChange(of: waypoint.id, initial: true) { oldValue, newValue in
            position = .region(.init(center: waypoint, diameter: 2.nauticalMiles))
        }
    }
}

