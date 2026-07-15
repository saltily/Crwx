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
        case .seasonalChecklists:
            SeasonalChecklistsHome()
        case .menu:
            MenuHome()
        case .voyagePlanning:
            VoyagePlanHome()
        case .daysailPostArrival, .daysailPreDeparture,
                .cruisePostArrival, .cruisePreDeparture,
                .anchoragePreArrival, .anchoragePostArrival, .anchoragePreDeparture, .anchoragePostDeparture,
                .springUprig, .springLaunch, .springLoading, .springFitOut,
                .fallLayup, .fallDownrig, .fallHaulout, .fallOffloading, .winterMaintenance:
            if let checklist = path.checklist {
                AnyChecklistView(checklist: checklist)
            } else {
                Label("Missing Checklist", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .safetyEquipment, .generalInventory:
            AnyInventoryView()
        case .takeOut, .bringIn, .dockside, .purchase, .prepAshore:
            AnyPackingView()
        }
    }
}

#Preview {
    ListingPathDestinationView(path: .loadingAndInventory)
}
