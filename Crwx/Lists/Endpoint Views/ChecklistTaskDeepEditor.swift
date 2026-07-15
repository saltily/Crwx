//
//  ChecklistTaskDeepEditor.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import WxSalt

struct ChecklistTaskDeepEditor: View {
    let style: CheckableTask.S
    @Binding var items: [PackableItem]
    @Binding var itemToEdit: PackableItem?
    @Binding var steps: [CheckableTask]
    @Binding var taskToEdit: CheckableTask?
    @Binding var isEditing: Bool
    var body: some View {
        switch style {
        case .packing:
            ChecklistPackingEditorGuts(items: $items, itemToEdit: $itemToEdit)
        case .project:
            ChecklistProjectEditorGuts(items: $items, steps: $steps, taskToEdit: $taskToEdit, isEditing: $isEditing)
        case .plain:
            EmptyView()
        }
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
    @Previewable @State var isEditing = false
    NavigationStack {
        List {
            ChecklistTaskDeepEditor(style: .project, items: $items, itemToEdit: .constant(nil), steps: $steps, taskToEdit: .constant(nil), isEditing: $isEditing)
        }
        .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
