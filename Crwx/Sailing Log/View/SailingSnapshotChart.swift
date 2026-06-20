//
//  SailingSnapshotChart.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/8/25.
//

import SwiftUI
import MapKit
import FoundationUI
import FoundationSalt
import WxSalt

struct SailingSnapshotChart: View {
    init(model: SailingSnapshotViewModel, initialRegion: MKCoordinateRegion) {
        self.model = model
        self.initialRegion = initialRegion
        _region = .init(initialValue: initialRegion)
    }
    @Bindable var model: SailingSnapshotViewModel
    let initialRegion: MKCoordinateRegion
    @State private var region: MKCoordinateRegion
    @AppStorage(.preferredMapTypeKey) private var mapType: MapType = .noaa
    var body: some View {
        VStack(spacing: 15) {
            ChartMap(region: $region) { map in
                
                // snail trail
                map.line(model.history, .orange, thickness: 1)
                
                // route
                map.line(model.route.points, .gray)
                
                //            // dotted line to next waypoint
                //            map.line([model.currentLocation, model.route.points[i]], .red, thickness: 1, dash: [2, 8])
                //
                //            // red route overlay for remainder of route
                //            map.line(model.route.points[i...].array)
                //
                //            // lookahead track
                //            if let lookaheadPath {
                //                map.line(lookaheadPath, .mint)
                //                if let pin = lookaheadPath.last {
                //                    map.marker(point: pin, tint: .mint)
                //                }
                //            }
                //
                //            // start harbour link
                ////            HarbourLink(harbour: model.startHarbour)
                //
                //            // end anchorage link
                ////            DestinationLink(model: model)
                //
                //            // waypoint distances
                ////            ForEach(measured) { wp in
                ////                TrackDot(wp)
                ////            }
                //
                // current heading and speed
                map.currentSpeed(coordinate: model.currentLocation.coordinate, speed: model.spd, heading: model.hdg)
            }
            .northUp()
            .mapTypeControl($mapType, region: region, allowedTypes: .tiles)
            .onChange(of: initialRegion) { oldValue, newValue in
                region = newValue
            }
            SailingSnapshotOneLine(model: model)
        }
    }
}

fileprivate struct SailingSnapshotChartModifier: ViewModifier {
    let model: SailingSnapshotViewModel
    let initialRegion: MKCoordinateRegion
    func body(content: Content) -> some View {
        NavigationLink(destination: SailingSnapshotChart(model: model, initialRegion: initialRegion).seaBackground()) {
            content
        }
    }
}
extension View {
    func navigateToChart(_ model: SailingSnapshotViewModel, region: MKCoordinateRegion) -> some View {
        modifier(SailingSnapshotChartModifier(model: model, initialRegion: region))
    }
}
