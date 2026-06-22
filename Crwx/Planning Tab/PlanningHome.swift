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
        }
        .navigationTitle("Planning")
        .seaBackground()
    }
}

#Preview {
    PlanningHome()
}
