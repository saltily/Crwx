//
//  ChecklistTaskEditor.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import FoundationUI
import WxSalt
import FocusOnAppear

extension View {
    func checklistTaskEditor(_ taskToEdit: Binding<CheckableTask?>) -> some View {
        modifier(ChecklistTaskEditorSheetModifier(taskToEdit: taskToEdit))
    }
}
struct ChecklistTaskEditorSheetModifier: ViewModifier {
    @Binding var taskToEdit: CheckableTask?
    @Environment(PlanningRouter.self) private var router
    func body(content: Content) -> some View {
        content
            .sheet(item: $taskToEdit) { task in
                @Bindable var task = task
                NavigationStack {
                    ChecklistTaskEditor(task: task)
                        .seaBackground()
                        .saveButton()
                }
                .presentationDetents([.height(300)])
                .onChange(of: task.style) { oldValue, newValue in
                    if newValue != .plain {
                        taskToEdit = nil
                        router.path.append(task)
                    }
                }
            }
    }
}
struct ChecklistTaskEditor: View {
    @Bindable var task: CheckableTask
    @State private var itemToEdit: PackableItem?
    @State private var taskToEdit: CheckableTask?
    @State private var isEditing = false
    @FocusState private var focused
    var body: some View {
        List {
            ChecklistTaskDeepEditor(style: task.style, items: $task.packingList, itemToEdit: $itemToEdit, steps: $task.steps, taskToEdit: $taskToEdit, isEditing: $isEditing)
            Section {
                TextField("Untitled", text: $task.label, axis: .vertical)
                    .modifier(ConditionalFocusedModifier(focusOnAppear: task.style == .plain))
                TaskStylePicker(value: $task.style)
            }
            .seaSection()
        }
        .checklistEditorToolbar(style: task.style, items: $task.packingList, itemToEdit: $itemToEdit, steps: $task.steps, taskToEdit: $taskToEdit, isEditing: $isEditing, resets: false)
        .packingItemEditor($itemToEdit)
        .checklistTaskEditor($taskToEdit)
    }
}
#Preview {
    @Previewable @State var task: CheckableTask = .project
    @Previewable @State var router = PlanningRouter()
    NavigationStack(path: $router.path) {
        ChecklistTaskEditor(task: task)
            .seaBackground()
            .navigationDestination(for: CheckableTask.self) { task in
                ChecklistTaskEditor(task: task)
                    .seaBackground()
            }
    }
    .environment(\.wxColourScheme, .green)
    .environment(router)
}

fileprivate struct ConditionalFocusedModifier: ViewModifier {
    let focusOnAppear: Bool
    @FocusState private var focused
    @Environment(\.dismiss) private var dismiss
    func body(content: Content) -> some View {
        if focusOnAppear {
            content.focusOnAppear($focused)
        } else {
            content
        }
    }
}
