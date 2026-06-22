//
//  GridHelper.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/23/25.
//

import SwiftUI
import FoundationUI
import MapKit
import CoreLocation
import FoundationSalt

struct GridHelper: View {
    @State private var region: MKCoordinateRegion = .init(center: CLLocationCoordinate2D.default, diameter: .init(value: 48, unit: .nauticalMiles))
    @State private var points: [CLLocationCoordinate2D] = []
    @State private var mapType: MapType = .noaa
    var body: some View {
        let allPoints = points + [region.center]
        ZStack {
            ChartMap(region: $region) { map in
                map.line(allPoints, thickness: 2)
                for p in points {
                    map.marker(point: p.labelled(p.summary))
                }
            }
            .mapTypeControl($mapType, region: region, allowedTypes: .tiles) //, overlay: .grid, .radar)
            Button(systemImage: "scope") {
                points.append(region.center)
            }
            .tint(.pink)
            Text(region.center.summary)
                .foregroundStyle(.black)
                .fontWeight(.medium)
                .offset(y: 15)
        }
        .northUp()
    }
}

#Preview {
    GridHelper()
}

fileprivate extension CLLocationCoordinate2D {
    var summary: String {
        latitude.formatted(.number.precision(.fractionLength(3))) + ", " +
        longitude.formatted(.number.precision(.fractionLength(3)))
    }
}
