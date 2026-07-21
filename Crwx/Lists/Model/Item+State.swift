//
//  Item+State.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation

extension PackableItem {
    /// Helps me encapsulate what is ever evolving and unique about this instance.
    struct State: Codable, Sendable, Hashable {
        /// Where it currently is.
        var status: PackedStatus
        /// Means whether should be in list to advance.  Never would not be in a list.  Anytime would always be in a list.  Else will depend on today's date.  Tends to vary by lifecycle and status.
        var due: ActionTime
        /// How many are in play with this entry.  Can be representative of any quantity.  Make a note in specs to describe that.
        var quantity: Double = 1
        /// This is a means of keeping checked items visible in the previous list.  If something is on the boat but not confirmed, then it still appears in the list of things to bring out.  It also still appears on other lists.  Mark this true to hide checked items.
        var confirmed: Bool = false
        func stepPhrase(requiresDockside: Bool) -> String {
            let due = due
            let status = status
            var verb = status.thisVerb
            if requiresDockside {
                verb = "\(verb) dockside"
            }
            if due == .never {
                if status == .loadedOnBoat {
                    return "leave on boat"
                } else {
                    // wait to load
                    return "wait to \(verb)"
                }
            } else {
                // load dockside anytime
                return "\(verb) \(due.summary)"
            }
        }
    }
}
