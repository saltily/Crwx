//
//  Library+Electronics.swift
//  Crwx
//
//  Created by Matthew Goacher on 8/1/26.
//

import Foundation

/// 7 items
/// Imported 8/1/2026, 2:32 pm
extension PackableItemDefinition {
    static var flashlights: PackableItemDefinition {
        .init(id: UUID(uuidString: "3B702438-6946-4042-830F-CD591C23D816")!, name: "flashlights", category: .electronics, lifecycle: .permanent, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var spotlightFlashlight: PackableItemDefinition {
        .init(id: UUID(uuidString: "32209508-EA6F-48D8-B646-A99D7F0EAFCC")!, name: "spotlight flashlight", category: .electronics, lifecycle: .seasonal, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var phoneChargingCords: PackableItemDefinition {
        .init(id: UUID(uuidString: "F1769A6A-77E5-4213-997F-AC9C80303990")!, name: "phone charging cords", category: .electronics, lifecycle: .permanent, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var vhfRadios: PackableItemDefinition {
        .init(id: UUID(uuidString: "FE07E0EF-8495-4AFC-8486-6529B2D3247F")!, name: "vhf radios", category: .electronics, lifecycle: .seasonal, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var phone: PackableItemDefinition {
        .init(id: UUID(uuidString: "A1E32F0A-EF39-47F0-A876-C6DAA7A288E3")!, name: "phone", category: .electronics, lifecycle: .daysail, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var appleWatch: PackableItemDefinition {
        .init(id: UUID(uuidString: "7FA4F0DB-3F39-45EC-A049-EB45E571A42B")!, name: "apple watch", category: .electronics, lifecycle: .daysail, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var appleWatchingChargingBattery: PackableItemDefinition {
        .init(id: UUID(uuidString: "723F5BEA-47F7-4814-84E6-8EAFE71519D3")!, name: "apple watching charging battery", category: .electronics, lifecycle: .daysail, consumable: .consumable, locker: .navTable, requiresDockside: false)
    }
}
