//
//  HarboursMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/12/25.
//

import SwiftUI
import FoundationUI
import MapKit
import SwiftData
import FoundationSalt
import WxSalt

struct HarboursMap: View {
    @Query private var harbours: [Harbour]
    @State private var region: MKCoordinateRegion = .MaineCoast
    @State private var selected: Harbour?
    @State private var searchTerm: String = ""
    @State private var selectedRoute: (Route, Int)?
    @State private var colours: ColorPattern = .green
    @State private var showAllRoutes = false
    @Environment(\.modelContext) private var context
    var body: some View {
        let message = message
        ZStack {
            SaltMap(region: $region, selection: $selected) {
                ForEach(harbours) { harbour in
                    MapMarker(harbour).tag(harbour)
                }
                if showAllRoutes {
                    AllRoutePolylines(routes: selected?.routes ?? [], colours: colours)
                }
                else if let selectedRoute {
                    let waypoints = try? selectedRoute.0.waypoints(in: context)
                    Polyline(waypoints ?? [], tint: colours[selectedRoute.1])
                }
            }
            .northUp()
            .focusMap(on: $selected, region: $region, diameter: 10.nauticalMiles)
            ZoomControlsOverlay(region: $region, showAll: showAll)
        }
        .navigationTitle(title)
        .toolbarTitleDisplayMode(.inline)
        .searchable(text: $searchTerm)
        .onSubmit(of: .search) {
            if searchTerm.isEmpty {
                region = showAll
            } else {
                selected = harbours.filter { $0.name.localizedStandardContains(searchTerm) }.first
                if selected == nil { region = showAll }
            }
        }
        .onChange(of: selected) { oldValue, newValue in
            selectedRoute = nil
            showAllRoutes = false
        }
        .onChange(of: searchTerm) { oldValue, newValue in
            let matches = searchMatches
            if matches.count == 1 {
                selected = matches[0]
            }
        }
        .onChange(of: selectedRoute?.0) { oldValue, newValue in
            if newValue != nil {
                showAllRoutes = false
                region = showAll
            }
        }
        .navigationSubtitle(message)
        .safeAreaInset(edge: .bottom) {
            VStack {
                HStack {
                    Text(message).frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    if selected?.routes?.count.nilIfZero != nil {
                        Group {
                            Button("all") {
                                selectedRoute = nil
                                showAllRoutes = true
                                region = showAll
                            }
                            Button("clear") {
                                selectedRoute = nil
                                showAllRoutes = false
                            }
                        }
                        .clipShape(Capsule())
                        .font(.caption)
                        .buttonStyle(.bordered)
                        .tint(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
                if let selected {
                    HarbourRoutesSublist(selectedRoute: $selectedRoute, routes: selected.routes?.sorted(not: selected.id, in: context) ?? [], pattern: colours, harbourId: selected.id)
                        .seaBackground(.ultraThinMaterial)
                        .frame(height: min(200, 50 * CGFloat(selected.routes?.count ?? 0)))
                }
            }
        }
        .schemedColorPattern($colours)
    }
    
    private var title: String {
        selected?.name ?? "Routes by Harbour"
    }
    private var message: String {
        if !searchTerm.isEmpty {
            let count = searchMatches.count
            if count != 1 {
                return "\(count) matches"
            }
        }
        else if let selected {
            let routeCount = selected.routes?.count ?? 0
            return routeCount.appending("route", "routes")
        }
        return ""
    }
    private var searchMatches: [Harbour] {
        guard !searchTerm.isEmpty else { return [] }
        return harbours.filter { $0.name.localizedStandardContains(searchTerm) }
    }
    private var showAll: MKCoordinateRegion {
        if showAllRoutes,
           let routes = selected?.routes,
           !routes.isEmpty
        {
            return .fitting(points: routes.allWaypoints(in: context))
        }
        else if let selectedRoute,
                let waypoints = try? selectedRoute.0.waypoints(in: context)
        {
            return .fitting(points: waypoints)
        }
        return .fitting(points: harbours)
    }
}
