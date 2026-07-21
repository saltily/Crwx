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
    @Environment(\.addAnother) private var addAnother
    private var isPresentedBinding: Binding<Bool> {
        .init {
            itemToEdit != nil
        } set: { newValue in
            if !newValue {
                itemToEdit = nil
            }
        }
    }
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: isPresentedBinding) {
                if let item = itemToEdit {
                    NavigationStack {
                        PackingItemEditor(item: item)
                            .seaBackground()
                            .dismissButton("Done", systemImage: "checkmark", role: .confirm, placement: .topBarLeading)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button(systemImage: "plus") {
                                        addAnother()
                                    }
                                }
                            }
                    }
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
                    .modifier(ConditionalFocusedModifier(focusOnAppear: true, isEmpty: item.label.isEmpty))
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
