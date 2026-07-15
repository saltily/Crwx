//
//  ChecklistEditButtonModifier.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import WxSalt
import FoundationUI

extension View {
    /// This mimics `EditButton` but it allows me to change the order of items in the list when toggling the editing state.  It takes the rest of the toolbar content so it can build them in a single toolbar modifier with a spacer to ensure the edit button is its own glass element.  But it's delivered as a modifier so it can alter the edit mode state for all child views wrapped by the modifier.
    func checklistEditButton<Tools>(isEditing: Binding<Bool>, @ToolbarContentBuilder toolbarContent: @escaping () -> Tools) -> some View where Tools: ToolbarContent {
        modifier(ChecklistEditButtonModifier(isEditing: isEditing, toolbarContent: toolbarContent))
    }
}

struct ChecklistEditButtonModifier<Tools>: ViewModifier where Tools: ToolbarContent {
    @Binding var isEditing: Bool
    @ToolbarContentBuilder var toolbarContent: () -> Tools
    private var editMode: Binding<EditMode> {
        .init {
            isEditing ? .active : .inactive
        } set: { newValue in
            isEditing = newValue == .active
        }
    }
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Button {
                        withAnimation {
                            isEditing.toggle()
                        }
                    } label: {
                        if isEditing {
                            Image(systemName: "checkmark")
                        } else {
                            Text("Edit")
                        }
                    }
                    .tint(isEditing ? .accentColor : nil)
                    .buttonStyleProminent(if: isEditing)
                }
                ToolbarSpacer()
                toolbarContent()
            }
            .environment(\.editMode, editMode)
    }
}
fileprivate extension View {
    @ViewBuilder
    func buttonStyleProminent(if condition: Bool) -> some View {
        if condition {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.automatic) // Falls back to standard glass toolbar look
        }
    }
}
