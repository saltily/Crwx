//
//  ChecklistTaskLoop.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI

struct ChecklistTaskLoop: View {
    @Binding var steps: [CheckableTask]
    @Binding var taskToEdit: CheckableTask?
    @Binding var isEditing: Bool
    var body: some View {
        let ordered = isEditing ? steps : steps.checkedToBottom
        ForEach(ordered) { step in
            ChecklistTaskRow(task: step, taskToEdit: $taskToEdit)
        }
        .onMove { indices, i in
            steps.move(fromOffsets: indices, toOffset: i)
        }
        .onDelete { indices in
            steps.remove(atOffsets: indices)
        }
    }
}

#Preview {
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
    List {
        Section {
            ChecklistTaskLoop(steps: $steps, taskToEdit: $taskToEdit, isEditing: $isEditing)
        }
    }
    .checklistTaskEditor($taskToEdit)
}
