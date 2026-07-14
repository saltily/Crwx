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
