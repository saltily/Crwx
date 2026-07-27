//
//  InventoryListViewModel.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/23/26.
//

import Foundation

struct InventoryListViewModel {
    let style: InventoryListItem.Style
    var items: [InventoryListItem]
}


extension InventoryListViewModel {
    mutating func remove(id: UUID) {
        items.removeAll(where: { $0.id == id })
    }
}
