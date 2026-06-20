//
//  MapLink.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 11/30/23.
//

import SwiftUI
import MapKit
import FoundationUI
import WxSalt

struct MapLink<Location: WxLocation, Destination: View>: MapContent {
    
    init(location: Location, destination: Destination) {
        self.location = location
        self.destination = destination
    }
    private let location: Location
    @ViewBuilder private var destination: Destination
    var body: some MapContent {
        NavigationMapLink(location.label ?? "", systemImage: location.symbolName, coordinate: location.coordinate, tint: location.color, destination: destination)
    }
}

#Preview {
    NavigationStack {
        InteractivePreview()
    }
    .preferredColorScheme(.dark)
    .locationManager()
}
fileprivate struct InteractivePreview: View {
    @State private var location: TideStation = .default
    var body: some View {
        Map {
            MapLink(location: location, destination: LocationTideStationMapView(selection: $location))
        }
    }
}
