//
//  ChecklistsPlanning.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/22/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct ChecklistsPlanning: View {
    var body: some View {
        Section("Lists") {
            ListingPathLink(.loadingAndInventory)
            ListingPathLink(.projectsAndReminders)
            ListingPathLink(.daysailChecklists)
            ListingPathLink(.cruiseChecklists)
            ListingPathLink(.seasonalChecklists)
        }
        .seaSection()
    }
}

#Preview {
    NavigationStack {
        List {
            ChecklistsPlanning()
        }
        .navigationTitle("Checklists")
            .seaBackground()
            .navigationDestination(for: ListingPath.self) { path in
                ListingPathDestinationView(path: path)
                    .seaBackground()
                    .navigationTitle(path.label)
            }
    }
    .environment(\.wxColourScheme, .green)
}
