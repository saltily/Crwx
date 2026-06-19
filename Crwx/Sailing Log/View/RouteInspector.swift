//
//  RouteInspector.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/11/25.
//

import SwiftUI
import FoundationUI
import MapKit
import CoreLocation

struct RouteInspector: View {
    let route: RouteSnippet
    @State private var region: MKCoordinateRegion = .MaineCoast
    @State private var reference: CLLocationCoordinate2D?
    var body: some View {
        VStack(spacing: 0) {
            let measured = route.measured(from: reference)
            ZStack {
                SafeChartMap(region: $region) {
                    Polyline(route.points, tint: .gray)
                    ForEach(measured) { wp in
                        TrackDot(wp)
                    }
                    if let reference {
                        MapDot(reference)
                    }
                } legacy: { map in
                    map.line(route.points, .gray)
                    for wp in measured {
                        map.marker(wp, symbol: .waypoint, tint: .gray.opacity(0.1))
                    }
                    if let reference {
                        map.dot(reference)
                        map.line([reference, route.next(forward: reference)], thickness: 0.5, dash: [1,3])
                        map.line([reference, route.next(reverse: reference)], .teal, thickness: 0.8, dash: [0.5,2])
                    }
                }
                Button(systemImage: "scope") {
                    reference = region.center
//                    region = .fitting(points: route.points + [region.center])
                }
                .tint(.pink)
                CoordinateText(point: region.center)
                    .padding(.bottom, 10)
                    .mapAlignment(.bottom)
                    .foregroundStyle(.pink)
                    .font(.footnote)
            }
            .frame(height: 500)
            .onChange(of: route, initial: true) { oldValue, newValue in
                region = .fitting(points: route.points)
            }
            List {
                Section {
                    
                    Text("Hi")
                }
                .seaSection()
            }
            .listStyle(.grouped)
        }
        .seaBackground()
        .navigationTitle(route.name)
    }
}

