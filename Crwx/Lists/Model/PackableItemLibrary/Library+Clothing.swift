//
//  Library+Clothing.swift
//  Crwx
//
//  Created by Matthew Goacher on 8/1/26.
//

import Foundation


/// 6 items
/// Imported 8/1/2026, 2:29 pm
extension PackableItemDefinition {
    static var spareSocksPantsUndershirtsOrangeSweater: PackableItemDefinition {
        .init(id: UUID(uuidString: "3CDB8EDA-F5BB-4FB1-9ECD-142FD525FFC4")!, name: "spare socks, pants, undershirts, orange sweater", category: .clothing, lifecycle: .seasonal, consumable: nil, locker: .veeBerth, requiresDockside: false)
    }
    static var socks: PackableItemDefinition {
        .init(id: UUID(uuidString: "69E238CC-FFEC-4C82-8961-DD7752A24AFC")!, name: "socks", category: .clothing, lifecycle: .cruise, consumable: nil, locker: .veeBerth, requiresDockside: false)
    }
    static var underwear: PackableItemDefinition {
        .init(id: UUID(uuidString: "FFCECC3B-63A2-4796-94F8-4E0534FC47FA")!, name: "underwear", category: .clothing, lifecycle: .cruise, consumable: nil, locker: .veeBerth, requiresDockside: false)
    }
    static var pants: PackableItemDefinition {
        .init(id: UUID(uuidString: "74472FF7-1F5F-477D-8518-7E3EA82E2E48")!, name: "pants", category: .clothing, lifecycle: .cruise, consumable: nil, locker: .veeBerth, requiresDockside: false)
    }
    static var shirts: PackableItemDefinition {
        .init(id: UUID(uuidString: "A3C74C1F-BF69-48BB-A938-13B63EE0B1B3")!, name: "shirts", category: .clothing, lifecycle: .cruise, consumable: nil, locker: .veeBerth, requiresDockside: false)
    }
    static var swimmingCostume: PackableItemDefinition {
        .init(id: UUID(uuidString: "F3C7D809-19C0-4B00-BDA3-45B614750D2D")!, name: "swimming costume", category: .clothing, lifecycle: .cruise, consumable: nil, locker: .veeBerth, requiresDockside: false)
    }
}
