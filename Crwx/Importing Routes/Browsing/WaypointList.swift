//
//  WaypointList.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import SwiftData

struct WaypointList: View {
    @Query<Waypoint>(sort: .defaultOrder) private var waypoints: [Waypoint]
    var body: some View {
        List {
            Group {
                Section {
                    let standalone = waypoints.filter({ $0.isStandalone })
                    NavigationLink(destination: WaypointsMap(waypoints: standalone)) {
                        Label("All Standalone Waypoints", systemImage: "map")
                    }
                }
                ForEach(waypoints.grouped(by: \.isStandalone.int.inverse)) { group in
                    Section {
                        ForEach(group) { waypoint in
                            NavigationLink(destination: WaypointMap(waypoint: waypoint)) {
                                WaypointSummary(waypoint: waypoint)
                            }
                        }
                    }
                }
            }
            .seaSection()
        }
        .listFooter(countSentence)
        .navigationTitle("Waypoints")
    }
    private var countSentence: String {
        var strings = [String]()
        let standalone = waypoints.count(where: {
            $0.isStandalone
        })
        let routePoints = waypoints.count - standalone
        if standalone > 0 { strings.append(standalone.appending("standalone", "standalone")) }
        if routePoints > 0 { strings.append(routePoints.appending("route point", "route points")) }
        return strings.joined(separator: ", ")
    }
}

#Preview {
    WaypointList()
}
