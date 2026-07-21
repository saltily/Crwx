//
//  PackingListViewModel.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import Foundation

/// A subset of items optimised for the view so we can check them off.
struct PackingListViewModel {
    let filter: PackingFilter
    /// Contains the item but additional editable checked state to work better with the row in the view.
    var items: [PackingListItem]
}

extension PackingListViewModel {
    var subtitleSentence: String {
        let count = items.count(where: { !$0.checkedState.isChecked })
        return filter.countSentence(count)
    }
}
