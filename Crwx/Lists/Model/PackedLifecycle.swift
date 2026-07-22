//
//  Item+Lifecycle.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation

/// Items that we should automatically look to take out or bring in based upon daysail, cruise, season, completion of project, etc.
/// Can have more than one match.  Perishable and consumable we're more likely to want to review to see if they need to be purchased or deleted from inventory.
enum PackedLifecycle: String, Codable, Sendable, Hashable, CaseIterable {
    /// Like as soon as it goes to the boat, think about bringing it back on the next dinghy run.
    case fleeting
    // project might require unique id to know which project, but that will make difficult to choose from a picker
    // perhaps when you start or finish a project, it can show you everything to take out or bring in and let you mark them as due if appropriate - "Should any of these items come in?"
    case daysail, cruise, seasonal, project
    case perishable, consumable
}
