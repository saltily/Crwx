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
            Section {
                Text("It would probably be nice to have some basic stats about the next or currently planned cruise.  Also maybe change icons to checkmarks on checklists that have been done or are likely to come next.  That could be a cached next checklist and it could check off all checklists before next and next could be half complete.  Could automatically advance this when completing a checklist.  Could know based on where we are in the voyage plan whether likely to start over with anchoring or finish up the trip when arriving at last stop.")
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
