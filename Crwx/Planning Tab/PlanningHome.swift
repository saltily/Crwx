//
//  PlanningHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/22/26.
//

import SwiftUI
import WxSalt

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
    }
}

#Preview {
    PlanningHome()
}
