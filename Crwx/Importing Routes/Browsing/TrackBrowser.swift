//
//  TrackBrowser.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import WxSalt
import SwiftData

struct TrackBrowser: View {
    var body: some View {
        List {
            Group {
                Section {
                    ForEach(TrackBrowserType.allCases) { type in
                        switch type {
                        case .tracks:
                            TrackBrowserRow(Track.self, type)
                        case .routes:
                            TrackBrowserRow(Route.self, type)
                        case .waypoints:
                            TrackBrowserRow(Waypoint.self, type)
                        }
                    }
                    HarboursRow()
                }
                Section {
                    NavigationLink(destination: CoordinateBrowser()) {
                        Label("Coordinate Browser", systemImage: "scope")
                    }
                    AddRouteButton()
                    HubsLink()
                    NavigationLink(destination: HarboursMap()) {
                        Label("Harbours Map", systemImage: "map")
                    }
                }
            }
            .seaSection()
        }
        .navigationTitle("Tracks & Routes")
        .seaBackground()
    }
}

#Preview {
    NavigationStack {
        TrackBrowser()
    }
    .modelContainer(previewContainer)
}
