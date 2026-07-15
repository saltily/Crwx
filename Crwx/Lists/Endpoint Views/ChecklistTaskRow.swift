//
//  ChecklistTaskRow.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct ChecklistTaskRow: View {
    @Bindable var task: CheckableTask
    @Binding var taskToEdit: CheckableTask?
    @Environment(\.editMode) private var editMode
    @Environment(PlanningRouter.self) private var router
    var body: some View {
        HStack(spacing: 10) {
            if editMode?.wrappedValue != .active {
                TaskIsCheckedButton(isOn: $task.isChecked)
            }
            PlaceholderText(task.label, placeholder: "Untitled")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
                .onTapGesture {
                    if task.style == .plain {
                        taskToEdit = task
                    } else {
                        router.path.append(task)
                    }
                }
            if let action = task.action {
                TaskActionButton(action: action)
            }
        }
    }
}

#Preview {
    @Previewable @State var task: CheckableTask = "Do something.\nMultiple lines."
    NavigationStack {
        List {
            ChecklistTaskRow(task: task, taskToEdit: .constant(nil))
                .seaSection()
        }
        .seaBackground()
        .toolbar {
            ToolbarItem {
                EditButton()
            }
        }
    }
    .environment(\.wxColourScheme, .green)
}

fileprivate struct TaskIsCheckedButton: View {
    @Binding var isOn: Bool
    var body: some View {
        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
            .frame(width: 36, height: 36)
            .font(.title)
            .fontWeight(isOn ? .regular : .thin)
            .contentShape(.circle)
            .onTapGesture {
                withAnimation {
                    isOn.toggle()
                }
            }
            .foregroundStyle(isOn ? .accentColor : Color.primary)
    }
}
