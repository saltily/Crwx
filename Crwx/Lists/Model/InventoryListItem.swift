//
//  InventoryListItem.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/23/26.
//

import Foundation
import FoundationSalt

/// Rough sketch placeholder for a viewmodel.  We'll want this to have a packable item backing.  And it will need to know if we're doing boat or shore inventory.  And update last inventoried when changing stuff.
/// I want this to rollback like `PackingListItem`.
@Observable
final class InventoryListItem {
    init(checked: Bool = false, quantity: Double = 1) {
        self.checked = checked
        self.quantity = quantity
    }
    var checked: Bool {
        didSet {
            lastInventoried = checked ? .now : uncheckedLastInventoried
        }
    }
    var quantity: Double
    var uncheckedLastInventoried: Date? = .now.adding(weeks: -3)
    var lastInventoried: Date?
}

extension InventoryListItem {
    var label: String { "propane bottles" }
    var specs: String? { "Per bottle. Small camping bottles purchased in 4-pack from Amazon." }
    var nextStepsSentence: String { "Load dockside anytime, then leave on boat." }
    var matchingCountSentence: String? { "Maybe 2 on shore." }
    var historySentence: String? {
        guard let uncheckedLastInventoried else { return nil }
        let s = uncheckedLastInventoried.formatted(.relative(presentation: .named))
        return "Last inventoried \(s)."
    }
}
