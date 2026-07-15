//
//  CheckableTask.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import Foundation

/// This is likely to replace the ``TaskItemViewModel``.  Starting with this as something to help me play around with checklist interface as an initial starting point for brainstorming stuff that might go into checklists.  Mutable in some ways, but not persistent yet.
///
/// I want these to have a stable id that is not dependent on the label (which could be duplicate) so that it can track for reordering and such.
@Observable
final class CheckableTask: Identifiable, Codable, Sendable {
    let id: UUID
    var label: String
    var checkedOff: Date?
    init(id: UUID, label: String, checkedOff: Date? = nil) {
        self.id = id
        self.label = label
        self.checkedOff = checkedOff
    }
}

extension CheckableTask: ExpressibleByStringLiteral {
    convenience init(stringLiteral value: String) {
        self.init(id: .init(), label: value)
    }
    var isChecked: Bool {
        get { checkedOff != nil }
        set {
            guard newValue != isChecked else { return }
            checkedOff = newValue ? .now : nil
        }
    }
}
