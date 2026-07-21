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
    @State private var store: PackingStore = .sample
    var body: some View {
        List {
            WeatherPlanning()
            ChecklistsPlanning()
            DatabasePlanning()
            HistoryPlanning()
            
            Section("Deprecated") {
                PlanningPathLink(.coordinateBrowser)
            }
            .seaSection()
        }
        .navigationTitle("Planning")
        .seaBackground()
        .navigationDestination(for: ListingPath.self) { path in
            ListingPathDestinationView(path: path)
                .seaBackground()
                .navigationTitle(path.label)
                .environment(store)
        }
        .navigationDestination(for: WeatherPath.self) { path in
            WeatherPathDestinationView(path: path)
                .seaBackground()
        }
        .navigationDestination(for: Sounding.T.self) { type in
            SoundingsList(type: type)
                .seaBackground()
        }
        .navigationDestination(for: PlanningPath.self) { path in
            PlanningPathDestinationView(path: path)
                .seaBackground()
        }
        .navigationDestination(for: CheckableTask.self) { task in
            ChecklistTaskEditor(task: task)
                .seaBackground()
                .environment(store)
        }
        .environment(store)
    }
}

#Preview {
    NavigationStack {
        PlanningHome()
    }
    .locationManager()
    .environment(\.wxColourScheme, .green)
}
