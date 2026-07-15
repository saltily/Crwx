//
//  ChecklistViewModel.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import Foundation
import FoundationSalt

/// Encapsulates functionality for the checklists interface where can mutate what is checked off, order of items, text of items, and adding and removing items.  Will eventually want to find ways to persist these edits.
struct ChecklistViewModel {
    /// Manually ordered.
    var steps: [CheckableTask]
}

extension ChecklistViewModel: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: CheckableTask...) {
        self.steps = elements
    }
    /// Moves checked items to the bottom, with most recently checked above others.
    var orderedSteps: [CheckableTask] {
        let unchecked = steps.filter({ !$0.isChecked })
        let checked = steps.filter({ $0.isChecked }).sorted(by: \.checkedOff, order: .reverse)
        return unchecked + checked
    }
    mutating func reset() {
        for i in 0..<steps.count {
            steps[i].isChecked = false
        }
    }
    var lastUsed: Date? {
        steps.compactMap(\.checkedOff).max()
    }
    var subtitleString: String {
        guard let lastUsed else { return "" }
        let s = lastUsed.formatted(.dateTime.hour().minute().second())
        return "Last used: \(s)"
    }
}
