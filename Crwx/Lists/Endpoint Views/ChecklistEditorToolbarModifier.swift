//
//  ChecklistEditorToolbarModifier.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import FoundationUI


extension View {
    func checklistEditorToolbar(style: CheckableTask.S, items: Binding<[PackableItem]>, itemToEdit: Binding<PackableItem?>) -> some View {
        modifier(ChecklistEditorToolbarModifier(style: style, items: items, itemToEdit: itemToEdit))
    }
    func packingItemToolbar(items: Binding<[PackableItem]>, itemToEdit: Binding<PackableItem?>) -> some View {
        modifier(PackingItemToolbarModifier(items: items, itemToEdit: itemToEdit))
    }
}

struct ChecklistEditorToolbarModifier: ViewModifier {
    let style: CheckableTask.S
    @Binding var items: [PackableItem]
    @Binding var itemToEdit: PackableItem?
    func body(content: Content) -> some View {
        switch style {
        case .packing:
            content.packingItemToolbar(items: $items, itemToEdit: $itemToEdit)
        default:
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
