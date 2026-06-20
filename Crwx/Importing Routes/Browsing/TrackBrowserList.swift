//
//  TrackBrowserList.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI

struct TrackBrowserList: View {
    let type: TrackBrowserType
    var body: some View {
        switch type {
        case .tracks:
            TrackList()
        case .waypoints:
            WaypointList()
        case .routes:
            RouteList()
        }
    }
}

#Preview {
    TrackBrowserList(type: .tracks)
}
