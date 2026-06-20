//
//  RouteSummary.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import FoundationUI

struct RouteSummary: View {
    @Bindable var route: Route
    var body: some View {
        VStack(alignment: .leading) {
            PlaceholderText(route.name, placeholder: "Unnamed")
            (Text(route.endpointNames) + Text(", ") +
             Text(route.waypointIds.count.appending("waypoint", "waypoints")))
            .font(.caption)
        }
        .badge("\(route.length.formatted(.number.precision(.fractionLength(1)))) nm")
    }
}

