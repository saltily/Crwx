//
//  PackingItemEditor.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import WxSalt
import FoundationUI

extension View {
    func packingItemEditor(_ itemToEdit: Binding<PackableItem?>) -> some View {
        modifier(PackingItemEditorSheetModifier(itemToEdit: itemToEdit))
    }
}

struct PackingItemEditorSheetModifier: ViewModifier {
    @Binding var itemToEdit: PackableItem?
    func body(content: Content) -> some View {
        content
            .sheet(item: $itemToEdit) { item in
                NavigationStack {
                    PackingItemEditor(item: item)
                        .seaBackground()
                        .saveButton()
                }
            }
    }
}

struct PackingItemEditor: View {
    @Bindable var item: PackableItem
    var body: some View {
        List {
            Section {
                TextField("Untitled", text: $item.label, axis: .vertical)
            }
            .seaSection()
            Section {
                Text("And then this can get into other stuff like quantity and purchase or move which direction, yada, yada.")
            }
            .seaSection()
        }
    }
}

#Preview {
    @Previewable @State var item: PackableItem = "clear coat"
    NavigationStack {
        PackingItemEditor(item: item)
            .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
