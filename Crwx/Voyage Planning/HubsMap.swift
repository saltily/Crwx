//
//  HubsMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/17/25.
//

import SwiftUI
import MapKit
import FoundationUI
import SwiftData
import CoreLocation
import FoundationSalt

struct HubsMap: View {
    @Query private var waypoints: [Waypoint]
    @Query(filter: .hubs) private var hubs: [Waypoint]
    @State private var region: MKCoordinateRegion = .MaineCoast
    @State private var legs: [RouteSnippet] = []
    @Environment(\.modelContext) private var context
    @State private var selectedWaypoint: Waypoint?
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                SafeChartMap(region: $region) {
                    ForEach(legs) { leg in
                        Polyline(leg.points, tint: .gray, thickness: 1)
                    }
                    ForEach(hubs) { hub in
                        MapDot(hub, tint: .green)
                    }
                    ForEach(visibleWaypoints) { wp in
                        TrackDot(wp)
                    }
                    if let waypointAtScope,
                       waypointAtScope != selectedWaypoint
                    {
                        TrackDot(waypointAtScope, tint: .green)
                    }
                    if let selectedWaypoint {
                        MapDot(selectedWaypoint, tint: .indigo)
                    }
                } legacy: { map in
                    map.lines(legs.map { $0.points }, .gray, thickness: 1)
                    hubs.forEach { hub in
                        map.dot(hub, tint: .green)
                    }
                    visibleWaypoints.forEach { wp in
                        map.trackDot(wp)
                    }
                    if let waypointAtScope,
                       waypointAtScope != selectedWaypoint
                    {
                        map.trackDot(waypointAtScope, tint: .green)
                    }
                    if let selectedWaypoint {
                        map.dot(selectedWaypoint, tint: .indigo)
                    }
                }
                Button(systemImage: "scope") {
                    selectedWaypoint = waypointAtScope
                    if let selectedWaypoint {
                        region = .init(center: selectedWaypoint, diameter: .init(value: 0.75, unit: .nauticalMiles))
                    }
                }
                .tint(waypointAtScope == nil ? .gray : .accentColor)
            }
            List {
                Group {
                    if let selectedWaypoint {
                        HubInfo(waypoint: selectedWaypoint)
                    } else {
                        ZeroHeaderSection(20) {
                            Text("No selected waypoint.")
                        }
                    }
                }
                .seaSection()
            }
            .scrollDismissesKeyboard(.interactively)
            .environment(\.defaultMinListHeaderHeight, 0)
            .frame(height: 250)
            .seaBackground()
        }
        .navigationTitle("Hubs")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            region = .fitting(points: hubs)
        }
        .task {
            await loadAllRoutes()
        }
        .actions {
            WaypointDeduplicationButton()
        }
    }
    private func loadAllRoutes() async {
        let container = context.container
        let task = Task.detached {
            let actor = RouteLoader(modelContainer: container)
            return try await actor.allLegs().sorted()
        }
        do {
            self.legs = try await task.value
        } catch {
            logger.critical("Error loading all routes or deduplication candidates: \(error)")
        }
    }
    private var visibleWaypoints: [Waypoint] {
        guard region.span.longitudeDelta < 0.1 else { return [] }
        return waypoints.filter {
            !$0.isHub && region.contains($0) && $0 != waypointAtScope && $0 != selectedWaypoint
        }
    }
    private var waypointAtScope: Waypoint? {
        waypoints.scoped(in: region)
    }
}

#Preview {
    HubsMap()
}
