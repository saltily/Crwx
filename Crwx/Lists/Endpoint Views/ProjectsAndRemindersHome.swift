//
//  ProjectsAndRemindersHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct ProjectsAndRemindersHome: View {
    @State private var isEditing = false
    var body: some View {
        List {
            Section {
                Text("This will be a general ordered list of tasks to remind myself to do.  Some will be projects.  Some will be repairs.  Some will drill into subtasks.  Some will have lists of items to pack.")
                Text("I should be able to easily add stuff on the fly, drill in, mark as complete, see completed items filter to the bottom, delete (preferrably with shake to undo).")
                Text("Would be nice to be able to inject a sample store into the environment for use with previews.")
                Text("Probably also an edit button to drag to reorder in addition to just the plus to quickly add.")
                Text("I'll want to be able to filter in some ways.  Like which projects to do next.  Which to do underway on a cruise.  Which to do dockside.  Which to pack out on the next trip to the boat.  And then when marked complete, be sure to pack items back in.  So see it closely relate to the packing lists.")
            }
            .seaSection()
        }
        .checklistEditButton(isEditing: $isEditing) {
            ToolbarItem {
                Button(systemImage: "plus") {
                    
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectsAndRemindersHome()
            .navigationTitle("Projects & Reminders")
            .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
