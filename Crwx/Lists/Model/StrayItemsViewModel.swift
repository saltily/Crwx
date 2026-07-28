//
//  StrayItemsViewModel.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/28/26.
//

import Foundation

struct StrayItemsViewModel {
    var items: [PackableItem]
}


extension StrayItemsViewModel {
    mutating func remove(id: UUID) {
        items.removeAll(where: { $0.id == id })
    }
}
