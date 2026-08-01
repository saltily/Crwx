//
//  Library+Energy.swift
//  Crwx
//
//  Created by Matthew Goacher on 8/1/26.
//

import Foundation

/// 8 items
/// Imported 8/1/2026, 2:33 pm
extension PackableItemDefinition {
    static var fuelBottle: PackableItemDefinition {
        .init(id: UUID(uuidString: "205002D2-2C4B-410D-8536-300614418B9C")!, name: "fuel bottle", category: .energy, lifecycle: .permanent, consumable: nil, locker: .aftSettee, requiresDockside: false)
    }
    static var houseBatteries: PackableItemDefinition {
        .init(id: UUID(uuidString: "13873AC5-83A9-4F74-B3CC-DE7D0B630922")!, name: "house batteries", category: .energy, lifecycle: .seasonal, consumable: .expiring, locker: .cockpit, requiresDockside: true)
    }
    static var starterBattery: PackableItemDefinition {
        .init(id: UUID(uuidString: "0E847C53-12AA-4251-9D78-1185B69703A5")!, name: "starter battery", category: .energy, lifecycle: .seasonal, consumable: .expiring, locker: .cockpit, requiresDockside: true)
    }
    static var lighterStick: PackableItemDefinition {
        .init(id: UUID(uuidString: "FE182604-79C4-4494-87DB-1189962C8B0D")!, name: "lighter stick", category: .energy, lifecycle: .permanent, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var propaneBottles: PackableItemDefinition {
        .init(id: UUID(uuidString: "9DE51EFD-174C-498F-8342-80DF72EA18D6")!, name: "propane bottles", category: .energy, lifecycle: .permanent, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var waterHeater: PackableItemDefinition {
        .init(id: UUID(uuidString: "91BF3334-A592-4FD4-85B7-CF0825E29806")!, name: "water heater", category: .energy, lifecycle: .seasonal, consumable: nil, locker: .head, requiresDockside: true)
    }
    static var batteries: PackableItemDefinition {
        .init(id: UUID(uuidString: "A298277E-E1B8-4DF3-8E24-B47A887D3674")!, name: "batteries", category: .energy, lifecycle: .seasonal, consumable: .expiring, locker: .navTable, requiresDockside: false)
    }
    static var matches: PackableItemDefinition {
        .init(id: UUID(uuidString: "DB1AFFCC-6BFD-4E79-BB62-F600105FE60A")!, name: "matches", category: .energy, lifecycle: .seasonal, consumable: .consumable, locker: .portBookshelf, requiresDockside: false)
    }
}
