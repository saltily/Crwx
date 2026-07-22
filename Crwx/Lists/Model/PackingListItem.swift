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
    var checkedState: CheckedState {
        didSet {
            contents.update(status: uncheckedStatus.adding(state: checkedState))
            if !checkedState.isChecked {
                contents.state.due = uncheckedDue
                if checkedState == .unchecked {
                    contents.lastShift = uncheckedLastShift
                }
            }
        }
    }
    // support rollback when unchecking
    let uncheckedStatus: PackedStatus
    let uncheckedDue: ActionTime
    let uncheckedLastShift: PackableItem.Shift?
    var contents: PackableItem
    init(checkedState: CheckedState, contents: PackableItem, uncheckedStatus: PackedStatus, uncheckedDue: ActionTime, uncheckedLastShift: PackableItem.Shift?) {
        self.checkedState = checkedState
        self.contents = contents
        self.uncheckedStatus = uncheckedStatus
        self.uncheckedDue = uncheckedDue
        self.uncheckedLastShift = uncheckedLastShift
    }
}

extension PackingListItem {
    convenience init(contents: PackableItem, filter: PackingFilter) {
        self.init(checkedState: filter.checkedState(contents), contents: contents, uncheckedStatus: filter.uncheckedStatus(contents), uncheckedDue: contents.state.due, uncheckedLastShift: contents.lastShift)
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
