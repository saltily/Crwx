//
//  PackingListItem.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import Foundation
import FoundationSalt

struct PackingListItem {
    var checkedState: CheckedState
    var contents: PackableItem
}

extension PackingListItem {
    init(contents: PackableItem, filter: PackingFilter) {
        self.contents = contents
        self.checkedState = filter.checkedState(contents)
    }
}

extension PackingListItem: Identifiable, Comparable {
    var id: UUID { contents.id }
    /// Checked to the bottom, newest to the top.
    static func < (lhs: Self, rhs: Self) -> Bool {
        compare(lhs: lhs, rhs: rhs, using:
                .init(\.checkedState.isChecked.int),
                .init(\.contents.created, order: .reverse)
        ) == .orderedAscending
    }
}
