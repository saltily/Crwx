//
//  ChecklistTaskEditor.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import FoundationUI

extension View {
    func checklistTaskEditor(_ taskToEdit: Binding<CheckableTask?>) -> some View {
        modifier(ChecklistTaskEditor(taskToEdit: taskToEdit))
    }
}
struct ChecklistTaskEditor: ViewModifier {
    @Binding var taskToEdit: CheckableTask?
    func body(content: Content) -> some View {
        content
            .sheet(item: $taskToEdit) { task in
                @Bindable var task = task
                NavigationStack {
                    List {
                        TextField("Untitled", text: $task.label, axis: .vertical)
                    }
                    .saveButton()
                }
                .presentationDetents([.medium])
            }
    }
}
