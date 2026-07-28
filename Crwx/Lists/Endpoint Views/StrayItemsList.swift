//
//  StrayItemsList.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/24/26.
//

import SwiftUI
import WxSalt
import FoundationSalt
import FoundationUI

struct StrayItemsList: View {
    @Environment(PackingStore.self) private var store
    var body: some View {
        NestOne(model: store.strayItems())
    }
}
fileprivate struct NestOne: View {
    init(model: StrayItemsViewModel) {
        self.model = model
        self._mutable = .init(initialValue: model)
    }
    let model: StrayItemsViewModel
    @State private var mutable: StrayItemsViewModel
    var body: some View {
        NestTwo(model: $mutable)
            .onChange(of: model.items.map(\.id)) { oldValue, newValue in
                mutable = model
            }
    }
}
fileprivate struct NestTwo: View {
    @Binding var model: StrayItemsViewModel
    @State private var itemToEdit: PackableItem?
    @Environment(PackingStore.self) private var store
    var body: some View {
        List {
            Section {
                Text("These items do not appear in inventory lists or any active checklist to be shifted or as recently shifted.")
                Text("Consider deleting, flagging to include in inventory, or setting due for a shift.")
            }
            .seaSection()
            Section {
                ForEach(model.items) { item in
                        PackingItemGuts(item: item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                        .onTapGesture {
                            itemToEdit = item
                        }
                        .swipeDeleteWithConfirmation("Delete Permanently") {
                            Task {
                                withAnimation {
                                    model.remove(id: item.id)
                                }
                                store.remove(id: item.id)
                            }
                        }
                        .swipeOrderUpShift(item: item)
                }
            }
            .seaSection()
        }
        .navigationSubtitle(model.items.count.appending("item", "items"))
        .packingItemEditor($itemToEdit)
    }
}

#Preview {
    @Previewable @State var store: PackingStore = .sample
    NavigationStack {
        StrayItemsList()
            .seaBackground()
            .navigationTitle("Hidden Items")
    }
    .environment(\.wxColourScheme, .green)
    .environment(store)
}
