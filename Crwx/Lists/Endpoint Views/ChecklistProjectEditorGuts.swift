//
//  ChecklistProjectEditorGuts.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct ChecklistProjectEditorGuts: View {
    @Binding var items: [PackableItem]
    @Binding var steps: [CheckableTask]
    @Binding var taskToEdit: CheckableTask?
    @Binding var isEditing: Bool
    var body: some View {
        Section("Steps") {
            ChecklistTaskLoop(steps: $steps, taskToEdit: $taskToEdit, isEditing: $isEditing)
        }
        .seaSection()
        Section("Equipment") {
            NavigationLink(destination: ChecklistPackingEditor(items: $items)) {
                Text(items.map(\.label).joined(separator: ", "))
            }
        }
        .seaSection()
        Section {
            Text("These don't need to be hidden because they are sub to a project but the project might hide when completed.")
        }
        .seaSection()
    }
}

#Preview {
    @Previewable @State var items: [PackableItem] = [
        "clear coat",
        "garden sprayer",
        "foam roller",
        "step ladder",
        "nitrile gloves"
    ]
    @Previewable @State var steps: [CheckableTask] = [
        "Fill garden sprayer with clear coat.",
        "Setup ladder, gloves, and foam roller.",
        "Spray a section, then roll out with roller.",
        "Repeat until finished.",
        "Reclaim unused clear coat.",
        "Discard used sprayer, gloves, and roller cover."
    ]
    @Previewable @State var taskToEdit: CheckableTask?
    @Previewable @State var isEditing = false
    @Previewable @State var router = PlanningRouter()
    NavigationStack(path: $router.path) {
        List {
            ChecklistProjectEditorGuts(items: $items, steps: $steps, taskToEdit: $taskToEdit, isEditing: $isEditing)
        }
        .checklistTaskToolbar(steps: $steps, taskToEdit: $taskToEdit, isEditing: $isEditing, resets: false)
        .checklistTaskEditor($taskToEdit)
        .seaBackground()
        .navigationDestination(for: CheckableTask.self) { task in
            ChecklistTaskEditor(task: task)
                .seaBackground()
        }
    }
    .environment(\.wxColourScheme, .green)
    .environment(router)
}
