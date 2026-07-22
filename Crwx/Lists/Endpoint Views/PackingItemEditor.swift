//
//  PackingItemEditor.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import WxSalt
import FoundationUI
import FoundationSalt

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
    @State private var currentId: UUID?
    var body: some View {
        List {
            Section {
                TextField("Untitled", text: $item.label, axis: .vertical)
                    .lineLimit(2...)
                    .modifier(ConditionalFocusedModifier(focusOnAppear: true, isEmpty: item.label.isEmpty))
            } header: {
                Text("Label")
            } footer: {
                let sentences: [String?] = [
                    item.stepsSummary,
                    item.createdSentence,
                    item.shiftedSentence,
                    item.inventoriedSentence
                ]
                Text(sentences.compactMap({ $0 }).joined(separator: "  "))
                    .padding(.bottom)
            }
            .seaSection()
            PackingStateForm(model: $item.state, specs: $item.configuration.specs)
            PackingConfigurationForm(model: $item.configuration)
        }
        .onChange(of: item.id, initial: true) { oldValue, newValue in
            currentId = newValue
        }
        .onChange(of: item.state.status) { oldValue, newValue in
            if item.id == currentId,
               oldValue != newValue
            {
                item.lastShift = nil
            }
        }
    }
}

#Preview {
    @Previewable @State var item: PackableItem = "clear coat"
    NavigationStack {
        PackingItemEditor(item: item)
            .seaBackground()
            .onAppear {
                item.lastShift = .init(previous: .purchase)
                item.lastInventoried = .now.yesterday
            }
            .navigationTitle("Edit Packing Item")
            .navigationBarTitleDisplayMode(.inline)
    }
    .environment(\.wxColourScheme, .green)
}
