//
//  TripRouteMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/9/25.
//

import SwiftUI
import FoundationUI
import MapKit
import SwiftData
import FoundationSalt

/// - I want to show the departure harbour as a clickable link, going to harbour details.
/// - I want to show destination as a clickable link, going to anchorage potential.
struct TripRouteMap: View {
    let model: TripRouteViewModel
    @Bindable var live: TripRouteForm.LiveRoute
    @Environment(\.modelContext) private var context
    @State private var region: MKCoordinateRegion = .MaineCoast
    var body: some View {
        SaltMap(region: $region) {
            if let route = live.route {
                RoutePolyline(route: route, tint: .gray, region: region)
            }
            if let start = live.start {
                NavigationMapLink(start, symbol: start.symbol ?? .anchor, tint: nil, destination: HarbourDetail(harbour: start))
            }
            if live.end != nil {
                DestinationLink(live: live)
            }
        }
        .northUp()
//        ChartMap(region: $region) { map in
//            if let route = live.route {
//                map.line(route.points, .gray)
//            }
//            if let start = live.start {
//                map.marker(point: start)
//            }
//            if let end = live.end {
//                map.marker(point: end)
//            }
//        }
        // on change of model, zoom into its region that fits its points
        .onChange(of: model, initial: true) { oldValue, newValue in
            Task {
                await live.load(newValue, context: context)
                region = live.region
            }
        }
    }
    
}

fileprivate struct DestinationLink: MapContent {
    @Bindable var live: TripRouteForm.LiveRoute
    @AnchorageIntent private var intent
    @Environment(\.modelContext) private var context
    var body: some MapContent {
        if let anchorage {
            NestOne(engine: .init(modelContainer: context.container), anchorage: anchorage)
        }
    }
    private var anchorage: AnchoragePotential? {
        guard let start = live.start,
              let end = live.end
        else { return nil }
        return .init(harbour: end, start: .init(start), route: live.route, estimatedSpeed: intent.estimatedSpeed, etd: intent.estimatedDeparture, stayUntil: intent.stayUntil)
    }
}
fileprivate struct NestOne: MapContent {
    @State var engine: PotentialAnchorages.Engine
    @State var anchorage: AnchoragePotential
    var body: some MapContent {
        AnchorageLink(anchorage: $anchorage, engine: engine)
    }
}
