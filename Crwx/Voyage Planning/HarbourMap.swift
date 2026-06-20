//
//  HarbourMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import SwiftUI
import FoundationUI
import MapKit
import FoundationSalt

struct HarbourMap: View {
    @Bindable var harbour: Harbour
    let destination: HarbourViewModel?
    @State private var region: MKCoordinateRegion = .MaineCoast
    @AppStorage(.preferredMapTypeKey) private var mapType: MapType = .noaa
    var body: some View {
        ChartMap(region: $region) { map in
            map.marker(harbour)
            if let destination {
                map.marker(destination, tint: .red)
                if let route = destination.route {
                    map.line(route.points)
                }
            }
        }
        .mapTypeControl($mapType, region: region, allowedTypes: .tiles)
        .onChange(of: harbour, initial: true) { oldValue, newValue in
            reposition()
        }
        .onChange(of: destination) { oldValue, newValue in
            reposition()
        }
    }
    private func reposition() {
        if let destination {
            if let route = destination.route {
                region = .fitting(points: route.points)
            } else {
                region = .fitting(points: [harbour, destination])
            }
        } else {
            region = .init(center: harbour, diameter: .init(value: 0.5, unit: .nauticalMiles))
        }
    }
}
