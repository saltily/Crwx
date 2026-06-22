//
//  TrackBrowser.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import WxSalt
import SwiftData

struct TrackBrowser: View {
    var body: some View {
        List {
            Group {
                Section {
                    NavigationLink(destination: CoordinateBrowser()) {
                        Label("Coordinate Browser", systemImage: "scope")
                    }
                    AddRouteButton()
                    NavigationLink(destination: HarboursMap()) {
                        Label("Harbours Map", systemImage: "map")
                    }
                }
            }
            .seaSection()
        }
        .navigationTitle("Tracks & Routes")
        .seaBackground()
    }
}

#Preview {
    NavigationStack {
        TrackBrowser()
    }
    .modelContainer(previewContainer)
}
