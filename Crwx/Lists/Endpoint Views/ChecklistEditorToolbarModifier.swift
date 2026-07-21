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
        resets: Bool,
        order: SortOrder = .reverse
    ) -> some View {
        modifier(ChecklistTaskToolbarModifier(steps: steps, taskToEdit: taskToEdit, isEditing: isEditing, resets: resets, order: order))
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
            content.checklistTaskToolbar(steps: $steps, taskToEdit: $taskToEdit, isEditing: $isEditing, resets: resets, order: .forward)
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
                        addOne()
                    }
                }
            }
            .environment(\.addAnother, addOne)
            .environment(\.deleteExtraEmpty, deleteExtraEmpty)
    }
    private func addOne() {
        let new: PackableItem = ""
        items.insert(new, at: 0)
        itemToEdit = new
    }
    private func deleteExtraEmpty() {
        withAnimation {
            if items.first?.label.isEmpty == true {
                items.remove(at: 0)
            }
        }
        itemToEdit = nil
    }
}

struct ChecklistTaskToolbarModifier: ViewModifier {
    @Binding var steps: [CheckableTask]
    @Binding var taskToEdit: CheckableTask?
    @Binding var isEditing: Bool
    let resets: Bool
    let order: SortOrder
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
                        addOne()
                    }
                }
            }
            .environment(\.addAnother, addOne)
            .environment(\.deleteExtraEmpty, deleteExtraEmpty)
    }
    private func addOne() {
        let new: CheckableTask = ""
        taskToEdit = new
        withAnimation {
            switch order {
            case .forward:
                steps.append(new)
            case .reverse:
                steps.insert(new, at: 0)
            }
        }
    }
    private func deleteExtraEmpty() {
        withAnimation {
            switch order {
            case .forward:
                if steps.last?.label.isEmpty == true {
                    steps.remove(at: steps.count - 1)
                }
            case .reverse:
                if steps.first?.label.isEmpty == true {
                    steps.remove(at: 0)
                }
            }
        }
        taskToEdit = nil
    }
}
