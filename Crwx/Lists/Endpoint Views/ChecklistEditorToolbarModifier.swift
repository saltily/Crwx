//
//  ChecklistEditorToolbarModifier.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import FoundationUI


extension View {
    func checklistEditorToolbar(
        style: CheckableTask.S,
        items: Binding<[PackableItem]>,
        itemToEdit: Binding<PackableItem?>,
        steps: Binding<[CheckableTask]>,
        taskToEdit: Binding<CheckableTask?>,
        isEditing: Binding<Bool>,
        resets: Bool
    ) -> some View {
        modifier(ChecklistEditorToolbarModifier(style: style, items: items, itemToEdit: itemToEdit, steps: steps, taskToEdit: taskToEdit, isEditing: isEditing, resets: resets))
    }
    func packingItemToolbar(
        items: Binding<[PackableItem]>,
        itemToEdit: Binding<PackableItem?>
    ) -> some View {
        modifier(PackingItemToolbarModifier(items: items, itemToEdit: itemToEdit))
    }
    func checklistTaskToolbar(
        steps: Binding<[CheckableTask]>,
        taskToEdit: Binding<CheckableTask?>,
        isEditing: Binding<Bool>,
        resets: Bool
    ) -> some View {
        modifier(ChecklistTaskToolbarModifier(steps: steps, taskToEdit: taskToEdit, isEditing: isEditing, resets: resets))
    }
}

struct ChecklistEditorToolbarModifier: ViewModifier {
    let style: CheckableTask.S
    @Binding var items: [PackableItem]
    @Binding var itemToEdit: PackableItem?
    @Binding var steps: [CheckableTask]
    @Binding var taskToEdit: CheckableTask?
    @Binding var isEditing: Bool
    let resets: Bool
    func body(content: Content) -> some View {
        switch style {
        case .packing:
            content.packingItemToolbar(items: $items, itemToEdit: $itemToEdit)
        case .project:
            content.checklistTaskToolbar(steps: $steps, taskToEdit: $taskToEdit, isEditing: $isEditing, resets: resets)
        case .plain:
            content
        }
    }
}

struct PackingItemToolbarModifier: ViewModifier {
    @Binding var items: [PackableItem]
    @Binding var itemToEdit: PackableItem?
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem {
                    Button(systemImage: "plus") {
                        let new: PackableItem = ""
                        withAnimation {
                            items.insert(new, at: 0)
                        }
                        itemToEdit = new
                    }
                }
            }
    }
}

struct ChecklistTaskToolbarModifier: ViewModifier {
    @Binding var steps: [CheckableTask]
    @Binding var taskToEdit: CheckableTask?
    @Binding var isEditing: Bool
    let resets: Bool
    func body(content: Content) -> some View {
        content
            .checklistEditButton(isEditing: $isEditing) {
                if resets {
                    ToolbarItem {
                        Button(systemImage: "arrow.counterclockwise") {
                            withAnimation {
                                steps.reset()
                            }
                        }
                    }
                }
                ToolbarItem {
                    Button(systemImage: "plus") {
                        let new: CheckableTask = ""
                        taskToEdit = new
                        steps.insert(new, at: 0)
                    }
                }
            }
    }
}
