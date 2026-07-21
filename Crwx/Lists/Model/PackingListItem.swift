//
//  PackingListItem.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import Foundation
import FoundationSalt

@Observable
final class PackingListItem {
    var checkedState: CheckedState
    var contents: PackableItem
    init(checkedState: CheckedState, contents: PackableItem) {
        self.checkedState = checkedState
        self.contents = contents
    }
}

extension PackingListItem {
    convenience init(contents: PackableItem, filter: PackingFilter) {
        self.init(checkedState: filter.checkedState(contents), contents: contents)
    }
}

extension PackingListItem: Identifiable, Comparable {
    var id: UUID { contents.id }
    /// Checked to the bottom, newest to the top.
    static func < (lhs: PackingListItem, rhs: PackingListItem) -> Bool {
        compare(lhs: lhs, rhs: rhs, using:
                .init(\.checkedState.sortValue, order: .reverse),
                .init(\.contents.created, order: .reverse)
        ) == .orderedAscending
    }
    static func == (lhs: PackingListItem, rhs: PackingListItem) -> Bool {
        lhs.checkedState == rhs.checkedState &&
        lhs.contents == rhs.contents
    }
}
