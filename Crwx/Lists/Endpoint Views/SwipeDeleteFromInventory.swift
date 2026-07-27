//
//  SwipeDeleteFromInventory.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/26/26.
//

import SwiftUI

extension View {
    func swipeDeleteFromInventory(_ item: InventoryListItem, region: InventoryListItem.Style, removeFromView: @escaping (UUID) -> ()) -> some View {
        modifier(SwipeDeleteFromInventory(item: item, region: region, removeFromView: removeFromView))
    }
}

struct SwipeDeleteFromInventory: ViewModifier {
    @Bindable var item: InventoryListItem
    let region: InventoryListItem.Style
    let removeFromView: (UUID) -> ()
    @State private var confirm = false
    @Environment(PackingStore.self) private var store
    func body(content: Content) -> some View {
        content
            .swipeActions {
                Button("Delete", systemImage: "trash") {
                    confirm = true
                }
                .tint(.red)
            }
            .confirmationDialog("Delete from where?", isPresented: $confirm) {
                let id = item.id
                Button("Don't Track in \(region.rawValue.capitalized) Inventory") {
                    switch region {
                    case .boat:
                        item.contents.state.inventory.quantityOnBoat = 0
                        item.contents.state.inventory.includeInBoatInventory = false
                    case .shore:
                        item.contents.state.inventory.quantityOnShore = 0
                        item.contents.state.inventory.includeInShoreInventory = false
                    }
                    Task {
                        withAnimation {
                            removeFromView(id)
                        }
                    }
                }
                Button("Delete Everywhere", role: .destructive) {
                    store.remove(id: id)
                    Task {
                        withAnimation {
                            removeFromView(id)
                        }
                    }
                }
            }
    }
}
