//
//  DaysailChecklistsHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt

struct DaysailChecklistsHome: View {
    var body: some View {
        List {
            Section {
                ListingPathLink(.daysailPreDeparture)
                ListingPathLink(.daysailPostArrival)
            }
            .seaSection()
            Section {
                Text("This is a lot of empty real estate.  Could I select some att a glance stuff?  Maybe I make the next checlist button taller and have it list like common stuff to pack and how much is in the inventory on the boat.  Stuff that might be in the drilled list but helpful to me at a glance to be thinking about without drilling the rest of the way.")
            }
            .seaSection()
        }
    }
}

#Preview {
    NavigationStack {
        DaysailChecklistsHome()
            .navigationTitle("Daysail Checklists")
            .seaBackground()
            .navigationDestination(for: ListingPath.self) { path in
                ListingPathDestinationView(path: path)
                    .navigationTitle(path.label)
                    .seaBackground()
            }
    }
    .environment(\.wxColourScheme, .green)
}
