//
//  ChecklistEditorToolbarModifier.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import FoundationUI


extension View {
    func checklistEditorToolbar(style: CheckableTask.S, items: Binding<[PackableItem]>) -> some View {
        modifier(ChecklistEditorToolbarModifier(style: style, items: items))
    }
    func packingItemToolbar(items: Binding<[PackableItem]>) -> some View {
        modifier(PackingItemToolbarModifier(items: items))
    }
}

struct ChecklistEditorToolbarModifier: ViewModifier {
    let style: CheckableTask.S
    @Binding var items: [PackableItem]
    func body(content: Content) -> some View {
        switch style {
        case .packing:
            content.packingItemToolbar(items: $items)
        default:
            content
        }
    }
}

struct PackingItemToolbarModifier: ViewModifier {
    @Binding var items: [PackableItem]
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem {
                    Button(systemImage: "plus") {
                        withAnimation {
                            items.insert("", at: 0)
                        }
                    }
                }
            }
    }
}
