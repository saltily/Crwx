//
//  SailingSnapshotMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/8/25.
//

import SwiftUI
import MapKit
import FoundationUI

struct SailingSnapshotMap: View {
    @Bindable var model: SailingSnapshotViewModel
    @State private var region: MKCoordinateRegion = .MaineCoast
    @State private var lookaheadPath: [LocationSnippet]?
    @AppStorage(.preferredMapTypeKey) private var mapType: MapType = .default
    var body: some View {
        let measured = model.route.measured(from: model.currentLocation)
        let i = model.route.index(nextForwardFrom: model.currentLocation)
        SaltMap(region: $region) {
            
            // snail trail
            Polyline(model.history, tint: .orange, thickness: 1)
            
            // route
            Polyline(model.route.points, tint: .gray)
            
            // dotted line to next waypoint
            MapPolyline([model.currentLocation, model.route.points[i]])
                .stroke(.red, style: StrokeStyle(lineWidth: 2, dash: [2, 1]))
            
            // red route overlay for remainder of route
            Polyline(model.route.points[i...].array)
            
            // lookahead track
            if let lookaheadPath {
                Polyline(lookaheadPath, tint: .mint)
                if let pin = lookaheadPath.last {
                    Marker(pin)
                        .tint(.mint)
                }
            }
            
            // start harbour link
            HarbourLink(harbour: model.startHarbour)
            
            // end anchorage link
            DestinationLink(model: model)
            
            // waypoint distances
            ForEach(measured) { wp in
                TrackDot(wp)
            }
            
            // current heading and speed
            CurrentSpeedSymbol(coordinate: model.currentLocation.coordinate, speed: model.spd, heading: model.hdg)
            // actual current location
//            UserAnnotation()
            
//        } legacy: { map in
//            
//            // snail trail
//            map.line(model.history, .orange, thickness: 1)
//            
//            // route
//            map.line(model.route.points, .gray)
//
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
//            // current heading and speed
//            map.currentSpeed(coordinate: model.currentLocation.coordinate, speed: model.spd, heading: model.hdg)

        }
        .northUp()
        .mapTypeControl($mapType, region: region, allowedTypes: .apple)
        .navigateToChart(model, region: region)
        .task {
            region = .init(center: model.currentLocation, diameter: model.rangeInHour)
        }
//        .onChange(of: model.allPoints, initial: true) { oldValue, newValue in
//            region = .fitting(points: newValue)
//        }
        .sailingLookaheadOverlay(centre: region.center, model: model, path: $lookaheadPath)
    }
}


fileprivate struct HarbourLink: MapContent {
    let harbour: Harbour
    var body: some MapContent {
        NavigationMapLink(harbour, symbol: harbour.symbol ?? .anchor, tint: harbour.tint, destination: HarbourDetail(harbour: harbour))
    }
}

fileprivate struct DestinationLink: MapContent {
    @Bindable var model: SailingSnapshotViewModel
    @Environment(\.modelContext) private var context
    @AnchorageIntent private var intent
    var body: some MapContent {
        NestOne(engine: .init(modelContainer: context.container), anchorage: anchorage)
    }
    private var anchorage: AnchoragePotential {
        if let eta = model.eta, let ttg = model.ttg {
            return .init(harbour: model.endHarbour, start: .init(model.startHarbour), route: model.route, eta: eta, duration: ttg, distance: model.dtg, stayUntil: eta.tomorrow.withoutTime.addingTimeInterval(10.hour))
        } else {
            return .init(harbour: model.endHarbour, start: .init(model.startHarbour), route: model.route, estimatedSpeed: intent.estimatedSpeed, etd: model.startTime, stayUntil: model.startTime.tomorrow.withoutTime.addingTimeInterval(10.hour))
        }
    }
}
fileprivate struct NestOne: MapContent {
    @State var engine: PotentialAnchorages.Engine
    @State var anchorage: AnchoragePotential
    var body: some MapContent {
        AnchorageLink(anchorage: $anchorage, engine: engine)
    }
}
