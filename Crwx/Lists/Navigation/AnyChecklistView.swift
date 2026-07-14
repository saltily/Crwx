//
//  AnyChecklistView.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct AnyChecklistView: View {
    let checklist: Checklist
    var body: some View {
        List {
            Section {
                Text("Because most checklists have some common stuff going on.")
                Text("It's always just the one list of items, though the current state of that list is persisted.  We don't keep previous lists.  So we can wipe the list and start over afresh.  When wiping, it will restore to the default order on the list.")
                Text("When completing stuff on the list, it moves completed items to the bottom.  But if uncompleting, it restores them to their previous order.")
                Text("Some items have actions they will run when marking complete or uncomplete, such as adding items to packing list or removing them from the packing list.  But otherwise these items are basically pre-defined when defining a checklist.")
                Text("Might not hurt to show a date of when it was last tapped on.  Also might not hurt for the log book steps to have quick-links to the appropriate items.  And some of these things might also post notifications and reminders to do the list or certain items in the list like turning the anchor light on and off.")
            }
            .seaSection()
        }
        .toolbar {
            ToolbarItem {
                Button(systemImage: "arrow.counterclockwise") {
                    // be sure to alert confirmation first
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AnyChecklistView(checklist: .daysailPredeparture)
            .navigationTitle(ListingPath.daysailPreDeparture.label)
            .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
