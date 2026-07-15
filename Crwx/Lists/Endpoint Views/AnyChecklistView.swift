//
//  AnyChecklistView.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt
import FoundationUI
import os
import FoundationSalt

struct AnyChecklistView: View {
    init(checklist: Checklist) {
        self.checklist = checklist
        self._model = .init(initialValue: checklist.viewModel)
    }
    let checklist: Checklist
    @State private var model: ChecklistViewModel
    @State private var isEditing = false
    var body: some View {
        List {
            Section {
                ForEach(steps) { step in
                    ChecklistTaskRow(task: step)
                }
                .onMove { indices, i in
                    model.steps.move(fromOffsets: indices, toOffset: i)
                }
                .onDelete { indices in
                    model.steps.remove(atOffsets: indices)
                }
            }
            .seaSection()
            Section {
                Text("Because most checklists have some common stuff going on.")
                Text("It's always just the one list of items, though the current state of that list is persisted.  We don't keep previous lists.  So we can wipe the list and start over afresh.  When wiping, it will restore to the default order on the list.")
                Text("When completing stuff on the list, it moves completed items to the bottom.  But if uncompleting, it restores them to their previous order.")
                Text("Some items have actions they will run when marking complete or uncomplete, such as adding items to packing list or removing them from the packing list.  But otherwise these items are basically pre-defined when defining a checklist.")
                Text("Might not hurt to show a date of when it was last tapped on.  Also might not hurt for the log book steps to have quick-links to the appropriate items.  And some of these things might also post notifications and reminders to do the list or certain items in the list like turning the anchor light on and off.")
            }
            .seaSection()
        }
        .checklistEditButton(isEditing: $isEditing) {
            ToolbarItem {
                Button(systemImage: "arrow.counterclockwise") {
                    withAnimation {
                        model.reset()
                    }
                }
            }
            ToolbarItem {
                Button(systemImage: "plus") {
                    
                }
            }
        }
        .navigationSubtitle(model.subtitleString)
        .onChange(of: checklist) { oldValue, newValue in
            model = newValue.viewModel
        }
    }
    private var steps: [CheckableTask] {
        isEditing ? model.steps : model.orderedSteps
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
