//
//  Library+Food.swift
//  Crwx
//
//  Created by Matthew Goacher on 8/1/26.
//

import Foundation

/// 4 items
/// Imported 8/1/2026, 2:30 pm
extension PackableItemDefinition {
    static var iceJugs: PackableItemDefinition {
        .init(id: UUID(uuidString: "0C1199E1-BAD2-4DC2-BB0D-5E2E27B8B192")!, name: "ice jugs", category: .coldStorage, lifecycle: .cruise, consumable: .perishable, locker: .iceBox, requiresDockside: false)
    }
    static var iceBoxThermometer: PackableItemDefinition {
        .init(id: UUID(uuidString: "28862078-41AB-49BF-A72C-F006C2E8D24B")!, name: "ice box thermometer", category: .coldStorage, lifecycle: .permanent, consumable: nil, locker: .iceBox, requiresDockside: false)
    }
    static var iceBoxTrays: PackableItemDefinition {
        .init(id: UUID(uuidString: "7EE98FD9-363A-4DC8-9C3E-29570B5D3090")!, name: "ice box trays", category: .coldStorage, lifecycle: .permanent, consumable: nil, locker: .iceBox, requiresDockside: true)
    }
    static var yetiCooler: PackableItemDefinition {
        .init(id: UUID(uuidString: "728813F1-5422-417A-9F48-3138B5F0A09A")!, name: "yeti cooler", category: .coldStorage, lifecycle: .cruise, consumable: nil, locker: .iceBox, requiresDockside: false)
    }
}


/// 4 items
/// Imported 8/1/2026, 2:30 pm
extension PackableItemDefinition {
    static var gallonWaterJugs: PackableItemDefinition {
        .init(id: UUID(uuidString: "C79C1007-E659-4F62-936E-679711CCD4F4")!, name: "gallon water jugs", category: .drinks, lifecycle: .permanent, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var waterBottles: PackableItemDefinition {
        .init(id: UUID(uuidString: "E5D21B0E-8486-487A-AE63-4CFC6E37745C")!, name: "water bottles", category: .drinks, lifecycle: .permanent, consumable: .consumable, locker: .starboardBookshelf, requiresDockside: false)
    }
    static var sparklingWaters: PackableItemDefinition {
        .init(id: UUID(uuidString: "524EBF49-088E-44B0-9698-7DCA3D24A68C")!, name: "sparkling waters", category: .drinks, lifecycle: .seasonal, consumable: .consumable, locker: .starboardBookshelf, requiresDockside: false)
    }
    static var gingerBeer: PackableItemDefinition {
        .init(id: UUID(uuidString: "C9654139-DFB4-4E9E-A740-115E3211C684")!, name: "ginger beer", category: .drinks, lifecycle: .seasonal, consumable: .consumable, locker: .starboardBookshelf, requiresDockside: false)
    }
}


/// 14 items
/// Imported 8/1/2026, 2:31 pm
extension PackableItemDefinition {
    static var cherries: PackableItemDefinition {
        .init(id: UUID(uuidString: "CD81C69A-2209-4249-BD20-8E9D9D9D164B")!, name: "cherries", category: .food, lifecycle: .daysail, consumable: .perishable, locker: .galley, requiresDockside: false)
    }
    static var pistachios: PackableItemDefinition {
        .init(id: UUID(uuidString: "A7616FC8-7A17-44F4-8C57-0151C9610676")!, name: "pistachios", category: .food, lifecycle: .daysail, consumable: .perishable, locker: .galley, requiresDockside: false)
    }
    static var granolaBars: PackableItemDefinition {
        .init(id: UUID(uuidString: "2FD9180F-F9A4-41E8-88D2-78CC078BBBFD")!, name: "granola bars", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var crackers: PackableItemDefinition {
        .init(id: UUID(uuidString: "A568FD44-63CC-40B5-9B00-89AD7CE0DBAB")!, name: "crackers", category: .food, lifecycle: .seasonal, consumable: .perishable, locker: .galley, requiresDockside: false)
    }
    static var peanutButter: PackableItemDefinition {
        .init(id: UUID(uuidString: "DCB612A1-1573-4E11-8ABF-F7574C20EB1B")!, name: "peanut butter", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var oatmeal: PackableItemDefinition {
        .init(id: UUID(uuidString: "B7847E49-9419-4C78-8FE5-F6AD74D15B8C")!, name: "oatmeal", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var ramen: PackableItemDefinition {
        .init(id: UUID(uuidString: "7A8BBC04-3408-43AA-B14A-BE1CC33888F2")!, name: "ramen", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var bakedBeans: PackableItemDefinition {
        .init(id: UUID(uuidString: "3EE5CE08-83FB-43EE-99E6-E5BB789237F3")!, name: "baked beans", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var soupCans: PackableItemDefinition {
        .init(id: UUID(uuidString: "FBE80FE2-00C1-4D67-911A-380EA692A9AE")!, name: "soup cans", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var coffee: PackableItemDefinition {
        .init(id: UUID(uuidString: "3DE429FF-360C-477D-B126-4A6AE6AC495E")!, name: "coffee", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var tea: PackableItemDefinition {
        .init(id: UUID(uuidString: "D96A911A-8119-4342-AEA2-F1FFDD6578AA")!, name: "tea", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var sugar: PackableItemDefinition {
        .init(id: UUID(uuidString: "337BF64C-2E70-4A01-AD6F-96237DB6F008")!, name: "sugar", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var salt: PackableItemDefinition {
        .init(id: UUID(uuidString: "C69D06E2-4152-41C0-BA92-ED9E26196F14")!, name: "salt", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var pepper: PackableItemDefinition {
        .init(id: UUID(uuidString: "0135EC11-3D6A-477A-8FB8-2D41BD2D0D1D")!, name: "pepper", category: .food, lifecycle: .seasonal, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
}
