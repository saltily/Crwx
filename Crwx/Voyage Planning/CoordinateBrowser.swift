//
//  CoordinateBrowser.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import SwiftUI
import MapKit
import FoundationUI
import SwiftData

struct CoordinateBrowser: View {
    @Query private var harbours: [Harbour]
    @State private var region: MKCoordinateRegion = .MaineCoast
    @AppStorage(.preferredMapTypeKey) private var mapType: MapType = .noaa
//    @State private var showGrid = false
    var body: some View {
        ZStack {
            SafeChartMap(region: $region) {
                ForEach(harbours) { harbour in
                    Marker(harbour)
                }
            } legacy: { map in
                for harbour in harbours {
                    map.marker(harbour)
                }
            }
            Image(systemName: "plus")
                .font(.system(size: 8))
                .foregroundStyle(.black)
            ShareLink(item: region.center.formatted(.location.precision(.fractionLength(6)).compass(.never))) {
                Image(systemName: "scope")
                    .font(.title2)
                    .fontWeight(.light)
            }
            .tint(.black)
            ShareLink(item: coordinateCode) {
                Text(region.center, format: .location.precision(.fractionLength(6)))
                    .fontWeight(.bold)
            }
            .tint(.black)
            .padding()
            .mapAlignment(.bottomTrailing)
        }
    }
    private var coordinateCode: String {
        ".init(latitude: \(region.center.latitude.formatted(.number.precision(.fractionLength(6)))), longitude: \(region.center.longitude.formatted(.number.precision(.fractionLength(6)))))"
    }
}
//
//#Preview {
//    CoordinateBrowser()
//}
