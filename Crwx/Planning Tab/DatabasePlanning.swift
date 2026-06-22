//
//  DatabasePlanning.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/22/26.
//

import SwiftUI
import WxSalt

struct DatabasePlanning: View {
    var body: some View {
        Section("Database") {
            HarboursRow()
            TrackBrowserRow(Route.self, .routes)
            HubsLink()
            TrackBrowserRow(Waypoint.self, .waypoints)
        }
        .seaSection()
    }
}

#Preview {
    DatabasePlanning()
}
