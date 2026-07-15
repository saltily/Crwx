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
    var body: some View {
        Section("Equipment") {
            NavigationLink(destination: ChecklistPackingEditor(items: $items)) {
                Text(items.map(\.label).joined(separator: ", "))
            }
        }
        .seaSection()
        Section("Steps") {
            
            Text("These can be a full on checkable list just like with a checklist.")
            Text("You can manually order, see sorted to the bottom as checked.")
            Text("You can add and remove.")
            Text("You can further nest and develop.")
            Text("These don't need to be hidden because they are sub to a project but the project might hide when completed.")
            Text("The edit and add buttons will need to be differently purposed here.")
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
    NavigationStack {
        List {
            ChecklistProjectEditorGuts(items: $items, steps: $steps)
        }
        .checklistTaskToolbar(steps: $steps, taskToEdit: $taskToEdit, isEditing: $isEditing, resets: false)
        .checklistTaskEditor($taskToEdit)
        .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
