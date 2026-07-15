//
//  ChecklistTaskEditor.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import FoundationUI
import WxSalt

extension View {
    func checklistTaskEditor(_ taskToEdit: Binding<CheckableTask?>) -> some View {
        modifier(ChecklistTaskEditorSheetModifier(taskToEdit: taskToEdit))
    }
}
struct ChecklistTaskEditorSheetModifier: ViewModifier {
    @Binding var taskToEdit: CheckableTask?
    func body(content: Content) -> some View {
        content
            .sheet(item: $taskToEdit) { task in
                @Bindable var task = task
                NavigationStack {
                    ChecklistTaskEditor(task: task)
                        .seaBackground()
                        .saveButton()
                }
                .presentationDetents([.medium, .large])
            }
    }
}
struct ChecklistTaskEditor: View {
    @Bindable var task: CheckableTask
    var body: some View {
        List {
            Section {
                TextField("Untitled", text: $task.label, axis: .vertical)
                TaskStylePicker(value: $task.style)
            }
            .seaSection()
            ChecklistTaskDeepEditor(style: task.style)
        }
    }
}
#Preview {
    @Previewable @State var task: CheckableTask = .plain
    NavigationStack {
        ChecklistTaskEditor(task: task)
            .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
