//
//  PlanningHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/22/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct PlanningHome: View {
    var body: some View {
        List {
            WeatherPlanning()
            ChecklistsPlanning()
            DatabasePlanning()
            HistoryPlanning()
            
            Section("Deprecated") {
                NavigationLink(destination: CoordinateBrowser()) {
                    Label("Coordinate Browser", systemImage: "scope")
                }
            }
            .seaSection()
        }
        .navigationTitle("Planning")
        .seaBackground()
        .navigationDestination(for: ListingPath.self) { path in
            ListingPathDestinationView(path: path)
                .seaBackground()
                .navigationTitle(path.label)
        }
        .navigationDestination(for: WeatherPath.self) { path in
            WeatherPathDestinationView(path: path)
                .seaBackground()
        }
        .navigationDestination(for: Sounding.T.self) { type in
            SoundingsList(type: type)
                .seaBackground()
        }
    }
}

#Preview {
    NavigationStack {
        PlanningHome()
    }
    .locationManager()
    .environment(\.wxColourScheme, .green)
}
