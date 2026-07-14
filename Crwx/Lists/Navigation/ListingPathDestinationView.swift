//
//  ListingPathDestinationView.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI

struct ListingPathDestinationView: View {
    let path: ListingPath
    var body: some View {
        switch path {
        case .loadingAndInventory:
            LoadingAndInventoryHome()
        case .projectsAndReminders:
            ProjectsAndRemindersHome()
        case .daysailChecklists:
            DaysailChecklistsHome()
        case .cruiseChecklists:
            CruiseChecklistsHome()
        default:
            Text("Under Development")
        }
    }
}

#Preview {
    ListingPathDestinationView(path: .loadingAndInventory)
}
