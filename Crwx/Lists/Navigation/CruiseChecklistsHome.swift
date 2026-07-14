//
//  CruiseChecklistsHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt

struct CruiseChecklistsHome: View {
    var body: some View {
        List {
            Section("Checklists") {
                ListingPathLink(.cruisePreDeparture)
                ListingPathLink(.anchoragePreArrival)
                ListingPathLink(.anchoragePostArrival)
                ListingPathLink(.anchoragePreDeparture)
                ListingPathLink(.anchoragePostDeparture)
                ListingPathLink(.cruisePostArrival)
            }
            .seaSection()
            Section("Planning") {
                ListingPathLink(.menu)
                ListingPathLink(.voyagePlanning)
            }
            .seaSection()
        }
    }
}

#Preview {
    NavigationStack {
        CruiseChecklistsHome()
            .navigationTitle("Cruise Checklists")
            .seaBackground()
            .navigationDestination(for: ListingPath.self) { path in
                ListingPathDestinationView(path: path)
                    .navigationTitle(path.label)
                    .seaBackground()
            }
    }
    .environment(\.wxColourScheme, .green)
}
