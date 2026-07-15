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
            PlanningPathCountingLink(.harbours, type: Harbour.self)
            PlanningPathCountingLink(.routes, type: Route.self)
            PlanningPathFilteredCountingLink(.hubs, filter: .hubs)
            PlanningPathCountingLink(.waypoints, type: Waypoint.self)
        }
        .seaSection()
    }
}

#Preview {
    DatabasePlanning()
}
