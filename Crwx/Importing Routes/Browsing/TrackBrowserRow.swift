//
//  TrackBrowserRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import SwiftData

struct TrackBrowserRow<T>: View where T: PersistentModel {
    init(_: T.Type, _ type: TrackBrowserType) {
        self.type = type
    }
    let type: TrackBrowserType
    @State private var count: Int = 0
    var body: some View {
        NavigationLink {
            TrackBrowserList(type: type)
                .seaBackground()
        } label: {
            Label(type.label, systemImage: type.systemImage)
                .badge(count)
                .fetchCount(T.self, into: $count)
        }
    }
}

#Preview {
    TrackBrowserRow(Track.self, .tracks)
}

enum TrackBrowserType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case tracks, waypoints, routes
    var label: String {
        rawValue.capitalized
    }
    var systemImage: String {
        switch self {
        case .tracks:
            "location.north.line.fill"
        case .waypoints:
            "mappin.and.ellipse"
        case .routes:
            "chart.xyaxis.line"
        }
    }
}
