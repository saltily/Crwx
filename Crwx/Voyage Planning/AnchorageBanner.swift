//
//  AnchorageBanner.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/30/25.
//

import SwiftUI
import FoundationUI
import MapKit

struct AnchorageBanner: View {
    let anchorage: AnchoragePotential
    var body: some View {
        SaltMap {
            if let route = anchorage.route {
                Polyline(route.points, tint: .gray)
                // current location joining to route
                if let loc = anchorage.fromLocation {
                    Polyline([loc, route.next(forward: loc)])
                }
            }
            MapDot(anchorage.start, tint: .gray)
            MapDot(anchorage.named(), tint: anchorage.colour)
            // current location
            if let loc = anchorage.fromLocation {
                TrackDot(loc, tint: .red)
            }
        }
        .northUp()
        .panningDisabled()
        .zoomDisabled()
    }
}

struct AnchoragePanner: View {
    let anchorage: AnchoragePotential
    @State private var region: MKCoordinateRegion = .MaineCoast
    var body: some View {
        let nextWaypoint = self.nextWaypoint
        SafeChartMap(region: $region) {
            if let route = anchorage.route {
                Polyline(route.points, tint: .gray)
            }
            MapDot(anchorage.start, tint: .gray)
            MapDot(anchorage.named(), tint: anchorage.colour)
            if let loc = anchorage.fromLocation {
                if let nextWaypoint {
                    Polyline([loc, nextWaypoint], tint: .blue)
                }
                MapDot(loc)
            }
        } legacy: { map in
            if let route = anchorage.route {
                map.line(route.points)
            }
            map.marker(point: anchorage.start, tint: .gray)
            map.marker(point: anchorage.named(), tint: anchorage.colour)
            if let loc = anchorage.fromLocation {
                if let nextWaypoint {
                    map.line([loc, nextWaypoint], .blue)
                }
                map.dot(loc)
            }
        }
        .navigationTitle(anchorage.name)
        .onChange(of: anchorage, initial: true) { oldValue, newValue in
            region = .init(center: anchorage, diameter: .init(value: 0.5, unit: .nauticalMiles))
        }
    }
    private var nextWaypoint: WaypointSnippet? {
        guard let loc = anchorage.fromLocation
        else { return nil }
        return anchorage.route?.next(forward: loc)
    }
}
