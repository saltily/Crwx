//
//  PlanningPathDestinationView.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI

struct PlanningPathDestinationView: View {
    let path: PlanningPath
    var body: some View {
        switch path {
        case .harbours:
            HarbourChooser()
        case .routes:
            TrackBrowserList(type: .routes)
        case .hubs:
            HubsMap()
        case .waypoints:
            TrackBrowserList(type: .waypoints)
        case .cruises:
            CruisesList()
        case .tracks:
            TrackBrowserList(type: .tracks)
        case .coordinateBrowser:
            CoordinateBrowser()
        }
    }
}

#Preview {
    PlanningPathDestinationView(path: .harbours)
}
