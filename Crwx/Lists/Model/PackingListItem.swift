//
//  PackingListItem.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import Foundation
import FoundationSalt

@Observable
final class PackingListItem: CheckedRollbackProtocol {
    var checkedState: CheckedState {
        didSet {
            contents.update(status: uncheckedRollback.status.adding(state: checkedState))
            rollback()
        }
    }
    // support rollback when unchecking
    let uncheckedRollback: Rollback
    var contents: PackableItem
    init(checkedState: CheckedState, contents: PackableItem, rollback: Rollback) {
        self.checkedState = checkedState
        self.contents = contents
        self.uncheckedRollback = rollback
    }
    struct Rollback {
        let status: PackedStatus
        let due: ActionTime
        let inventory: PackableItem.Inventory
        let lastShift: PackableItem.Shift?
    }
    func rollback() {
        if checkedState == .unchecked {
            contents.state.due = uncheckedRollback.due
            contents.state.inventory = uncheckedRollback.inventory.copy()
            contents.lastShift = uncheckedRollback.lastShift
        }
    }
}

extension PackingListItem {
    convenience init(contents: PackableItem, filter: PackingFilter) {
        let currentState = filter.checkedState(contents)
        let uncheckedStatus = filter.uncheckedStatus(contents)
        let uncheckedDue: ActionTime
        let uncheckedInventory: PackableItem.Inventory
        let uncheckedLastShift: PackableItem.Shift?
        if currentState.isChecked {
            uncheckedDue = contents.lastShift?.previousDue ?? .anytime
            uncheckedInventory = contents.state.inventory.rollback(from: contents.state.status, to: uncheckedStatus)
            uncheckedLastShift = nil
        } else {
            uncheckedDue = contents.state.due
            uncheckedInventory = contents.state.inventory
            uncheckedLastShift = contents.lastShift
        }
        self.init(checkedState: filter.checkedState(contents), contents: contents, rollback: .init(status: uncheckedStatus, due: uncheckedDue, inventory: uncheckedInventory, lastShift: uncheckedLastShift))
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
