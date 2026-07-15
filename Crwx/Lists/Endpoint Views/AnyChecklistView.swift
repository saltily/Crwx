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
    @State private var taskToEdit: CheckableTask?
    var body: some View {
        List {
            Section {
                ForEach(steps) { step in
                    ChecklistTaskRow(task: step, taskToEdit: $taskToEdit)
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
                Text("Still need to persist edits somewhere.")
                Text("Some items have actions they will run when marking complete or uncomplete, such as adding items to packing list or removing them from the packing list.  But otherwise these items are basically pre-defined when defining a checklist.")
                Text("Might not hurt for the log book steps to have quick-links to the appropriate items.  And some of these things might also post notifications and reminders to do the list or certain items in the list like turning the anchor light on and off.")
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
                    let new: CheckableTask = ""
                    taskToEdit = new
                    model.steps.insert(new, at: 0)
                }
            }
        }
        .navigationSubtitle(model.subtitleString)
        .onChange(of: checklist) { oldValue, newValue in
            model = newValue.viewModel
        }
        .checklistTaskEditor($taskToEdit)
    }
    private var steps: [CheckableTask] {
        isEditing ? model.steps : model.orderedSteps
    }
}

#Preview {
    @Previewable @State var router = PlanningRouter()
    NavigationStack(path: $router.path) {
        AnyChecklistView(checklist: .daysailPredeparture)
            .navigationTitle(ListingPath.daysailPreDeparture.label)
            .seaBackground()
            .navigationDestination(for: CheckableTask.self) { task in
                ChecklistTaskEditor(task: task)
                    .seaBackground()
            }
    }
    .environment(\.wxColourScheme, .green)
    .environment(router)
}
