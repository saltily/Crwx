//
//  AnyInventoryView.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt
import FoundationUI
import FoundationSalt

struct AnyInventoryView: View {
    let style: InventoryListItem.Style?
    @Environment(PackingStore.self) private var store
    var body: some View {
        if let style {
            NestOne(style: style, store: store)
        }
    }
}
fileprivate struct NestOne: View {
    init(style: InventoryListItem.Style, store: PackingStore) {
        let model = store.inventory(style)
        self.model = model
        self._mutable = .init(initialValue: model)
    }
    let model: InventoryListViewModel
    @State private var mutable: InventoryListViewModel
    var body: some View {
        NestTwo(model: $mutable)
            .onChange(of: model.style) { oldValue, newValue in
                mutable = model
            }
    }
}
// MARK: This is the actual view
fileprivate struct NestTwo: View {
    @Binding var model: InventoryListViewModel
    @AppStorage(.inventoryGroupingKey) private var grouping: InventoryListItem.Grouping = .locker
    @State private var itemToEdit: PackableItem?
    @Environment(PackingStore.self) private var store
    var body: some View {
        let group = model.style == .boat ? grouping : .category
        List {
            ForEach(model.items.organise(by: group)) { group in
                Section(group.id.label) {
                    ForEach(group) { item in
                        InventoryRow(item: item, itemToEdit: $itemToEdit)
                    }
                }
                .seaSection()
            }
            Section {
                Text("Inventory is similar to but not the same as a regular checklist or a packing list.  The items in the inventory are related to and match items that are packed and currently on the boat.  But this allows editing a quantity.  It also has some fixed default minimum items, that may be quantity zero like on a predefined checklist.  But also we want to know the individual dates when each inventory item is updated.")
                Text("It's ok to have a zero quantity but sometimes we might want to delete an item entirely as something we no longer wish to track or have in stock going forward.  Checking off items on packing lists should also attempt to adjust inventory.")
                Text("It might be good to automatically have a double value for all packing items so that we can sum them together and edit this sum in the inventory.  On the back end likely to have some fusing of these.  Packing items aren't really a history but could match label while having different characteristics for lifecycle but still summing together for inventory on the boat.  But if multiple, will want to have some sort of logic for which is incrementing or decrementing or being deleted from the list of items in play.  Maybe we call them `PackableItem`.")
                Text("We also want to be able to search the inventory using a search field.  And we might want to filter or organise by category such as safety or parts or consumables, or by location on the boat, or by how recently it was inventoried, or whether we're wondering if we should pack it for an upcoming trip or menu or seasonal loading and replenishment or disposal of spoiled or expired items.")
                Text("Also with inventory it might be useful to make a note of the desired minimum amount such as flares, life jackets, or also ingredients for up-and-coming.  This could factor into a need to purchase or load when the amount is not enough.  And would be good to have some sort of way to track safety equipment expiration and even send reminders if something is going to need to be replenished due to expiring.")
                Text("We might desire to break inventory into smaller sections, either collapsible, or drill into the section.  Could be by category or location, etc.")
            }
            .seaSection()
        }
        .toolbar {
            if model.style == .boat {
                ToolbarItem {
                    InventoryGroupingPickerMenu(value: $grouping)
                }
            }
            ToolbarItem {
                Button(systemImage: "plus") {
                    addOne()
                }
            }
        }
        .navigationSubtitle("Last updated: 5 weeks ago")
        .packingItemEditor($itemToEdit, invertOrder: true)
    }
    private func addOne() {
        let new: PackableItem = model.style == .boat ? .newBoatInventory : .newShoreInventory
        withAnimation {
            model.items.append(.init(contents: new, style: model.style))
        }
        store.add(items: [new])
        itemToEdit = new
    }
}

#Preview {
    @Previewable @State var store: PackingStore = .sample
    NavigationStack {
        AnyInventoryView(style: .shore)
            .seaBackground()
            .navigationTitle("Shore Inventory")
    }
    .environment(\.wxColourScheme, .green)
    .environment(store)
}

extension String {
    static let inventoryGroupingKey = "com.saltily.Crwx.inventoryGroupingKey" // InventoryListItem.Grouping: Int
}
