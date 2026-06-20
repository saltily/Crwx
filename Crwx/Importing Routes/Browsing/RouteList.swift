//
//  RouteList.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import SwiftData
import FoundationSalt

struct RouteList: View {
    @Query<Route>(sort: .defaultOrder) private var routes: [Route]
    @State private var showProgress = false
    var body: some View {
        List {
            Group {
                ForEach(routes.grouped(by: \.start)) { group in
                    Section(group.id?.name ?? "") {
                        ForEach(group) { route in
                            NavigationLink(destination: RouteMap(waypointIds: route.waypointIds)) {
                                RouteSummary(route: route)
                            }
                        }
                    }
                }
            }
            .seaSection()
        }
        .routeCommands(showProgress: $showProgress)
        .listFooter(countSentence, showProgress: showProgress)
        .navigationTitle("Routes")
    }
    private var countSentence: String {
        routes.count.appending("route", "routes")
    }
}

#Preview {
    RouteList()
}
