//
//  Item+Configuration.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation

extension PackableItem {
    struct Configuration: Codable, Sendable {
        /// Make notes about units we're counting by, brand, where to buy it, expiration or other tips to know.
        var specs: String = ""
        /// Instructions to help determine whether this should be added to the shift list at conclusion of daysail, cruise, project, season, etc.  Most likely multiple would be to also be perishable or consumable.
        var lifecycle: Set<PackedLifecycle> = []
        /// Indicates whether when shifting to the boat it can be brought by dinghy, or the vessel will need to be brought dockside.
        var requiresDockside: Bool = false
        /// Optional to help ordering inventory to walk through vessel and see what's there as going through.
        var locker: StorageLocker?
        /// Optional to help grouping in inventory.
        var category: PackedCategory?
    }
}
