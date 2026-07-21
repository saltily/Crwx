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
        steps: Binding<[CheckableTask]>,
        taskToEdit: Binding<CheckableTask?>,
        isEditing: Binding<Bool>,
        resets: Bool,
        addOne: @escaping () -> (),
        deleteExtraEmpty: @escaping () -> ()
    ) -> some View {
        modifier(ChecklistEditorToolbarModifier(style: style, steps: steps, taskToEdit: taskToEdit, isEditing: isEditing, resets: resets, addOne: addOne, deleteExtraEmpty: deleteExtraEmpty))
    }
    func packingItemToolbar(
        addOne: @escaping () -> (),
        deleteExtraEmpty: @escaping () -> ()
    ) -> some View {
        modifier(PackingItemToolbarModifier(addOne: addOne, deleteExtraEmpty: deleteExtraEmpty, button: { EditButton() }))
    }
    func packingItemToolbar<Btn>(
        addOne: @escaping () -> (),
        deleteExtraEmpty: @escaping () -> (),
        @ViewBuilder button: @escaping () -> Btn
    ) -> some View where Btn: View {
        modifier(PackingItemToolbarModifier(addOne: addOne, deleteExtraEmpty: deleteExtraEmpty, button: button))
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
    @Binding var steps: [CheckableTask]
    @Binding var taskToEdit: CheckableTask?
    @Binding var isEditing: Bool
    let resets: Bool
    let addOne: () -> ()
    let deleteExtraEmpty: () -> ()
    func body(content: Content) -> some View {
        switch style {
        case .packing:
            content.packingItemToolbar(addOne: addOne, deleteExtraEmpty: deleteExtraEmpty)
        case .project:
            content.checklistTaskToolbar(steps: $steps, taskToEdit: $taskToEdit, isEditing: $isEditing, resets: resets, order: .forward)
        case .plain:
            content
        }
    }
}

struct PackingItemToolbarModifier<Btn>: ViewModifier where Btn: View {
    let addOne: () -> ()
    let deleteExtraEmpty: () -> ()
    @ViewBuilder var button: () -> Btn
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    button()
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
