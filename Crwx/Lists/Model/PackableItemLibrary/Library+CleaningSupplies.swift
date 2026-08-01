//
//  Library+CleaningSupplies.swift
//  Crwx
//
//  Created by Matthew Goacher on 8/1/26.
//

import Foundation

/// 27 items
/// Imported 8/1/2026, 2:28 pm
extension PackableItemDefinition {
    static var mopBucket: PackableItemDefinition {
        .init(id: UUID(uuidString: "3E2AFD58-7175-494C-AA17-56F7B9CFA1D1")!, name: "mop bucket", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .aftSettee, requiresDockside: true)
    }
    static var mop: PackableItemDefinition {
        .init(id: UUID(uuidString: "B9BA3CF3-BA7E-406D-BAF2-36BC4B2BD593")!, name: "mop", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .aftSettee, requiresDockside: false)
    }
    static var nitrileGloves: PackableItemDefinition {
        .init(id: UUID(uuidString: "BA59F2AF-A9E3-4446-B6F7-F985DB05E835")!, name: "nitrile gloves", category: .cleaningSupplies, lifecycle: .permanent, consumable: .consumable, locker: .aftSettee, requiresDockside: false)
    }
    static var rags: PackableItemDefinition {
        .init(id: UUID(uuidString: "D4398F10-D905-40EB-B784-0B2C97573445")!, name: "rags", category: .cleaningSupplies, lifecycle: .seasonal, consumable: .perishable, locker: .closets, requiresDockside: false)
    }
    static var recyclingTrashBin: PackableItemDefinition {
        .init(id: UUID(uuidString: "818B1CD5-573B-45D9-BCE3-DC7432C4C7FE")!, name: "recycling trash bin", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: true)
    }
    static var recyclingTrashLiners: PackableItemDefinition {
        .init(id: UUID(uuidString: "F73CAB4B-56BF-44CF-990D-F1DA729A1ED0")!, name: "recycling trash liners", category: .cleaningSupplies, lifecycle: .permanent, consumable: .consumable, locker: .cockpit, requiresDockside: false)
    }
    static var deckBuckets: PackableItemDefinition {
        .init(id: UUID(uuidString: "10AD5344-E50E-4059-9ED5-7A87FA5589E6")!, name: "deck buckets", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: false)
    }
    static var deckBrushes: PackableItemDefinition {
        .init(id: UUID(uuidString: "257BDA5B-93D3-408C-B38C-D775133C4C3E")!, name: "deck brushes", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: true)
    }
    static var largeSponges: PackableItemDefinition {
        .init(id: UUID(uuidString: "9368A471-687E-4D5A-86BD-97A089B8D918")!, name: "large sponges", category: .cleaningSupplies, lifecycle: .permanent, consumable: .perishable, locker: .cockpit, requiresDockside: false)
    }
    static var dishSoap: PackableItemDefinition {
        .init(id: UUID(uuidString: "EA93F20D-5D03-4CDA-BE0C-F297082A39C1")!, name: "dish soap", category: .cleaningSupplies, lifecycle: .permanent, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var galleyTrashCan: PackableItemDefinition {
        .init(id: UUID(uuidString: "7D682F22-6CB8-41D3-8CB5-8C94C44E34C7")!, name: "galley trash can", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .galley, requiresDockside: false)
    }
    static var trashCanLiners: PackableItemDefinition {
        .init(id: UUID(uuidString: "3D894067-3B42-4BF2-82CE-D15FF7AE18FE")!, name: "trash can liners", category: .cleaningSupplies, lifecycle: .permanent, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var dishwashingGloves: PackableItemDefinition {
        .init(id: UUID(uuidString: "DE69193E-5554-49FB-B119-ACDFDEE5FF3E")!, name: "dishwashing gloves", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .galley, requiresDockside: false)
    }
    static var dishSponge: PackableItemDefinition {
        .init(id: UUID(uuidString: "1DD635DE-8045-44B7-91E9-5EA6D92D4DA6")!, name: "dish sponge", category: .cleaningSupplies, lifecycle: .permanent, consumable: .perishable, locker: .galley, requiresDockside: false)
    }
    static var dishBrush: PackableItemDefinition {
        .init(id: UUID(uuidString: "33CAA2CD-C3D0-454F-8B3D-2EBD32F4C3F8")!, name: "dish brush", category: .cleaningSupplies, lifecycle: .permanent, consumable: .perishable, locker: .galley, requiresDockside: false)
    }
    static var surfaceCleaner: PackableItemDefinition {
        .init(id: UUID(uuidString: "4AFB43E3-35F6-44D5-ABCB-6983D3724336")!, name: "surface cleaner", category: .cleaningSupplies, lifecycle: .permanent, consumable: .consumable, locker: .galley, requiresDockside: false)
    }
    static var windex: PackableItemDefinition {
        .init(id: UUID(uuidString: "2A0A625E-0354-4B7F-ABA4-F87F4663C032")!, name: "windex", category: .cleaningSupplies, lifecycle: .permanent, consumable: .consumable, locker: .head, requiresDockside: false)
    }
    static var airFresheners: PackableItemDefinition {
        .init(id: UUID(uuidString: "A0DDDE50-0418-4062-8CBD-14B140052EB1")!, name: "air fresheners", category: .cleaningSupplies, lifecycle: .permanent, consumable: .consumable, locker: .head, requiresDockside: false)
    }
    static var dehumidifiers: PackableItemDefinition {
        .init(id: UUID(uuidString: "4052DB53-7DF5-4FD6-9AD3-486969FC3024")!, name: "dehumidifiers", category: .cleaningSupplies, lifecycle: .seasonal, consumable: .expiring, locker: .head, requiresDockside: false)
    }
    static var handSoap: PackableItemDefinition {
        .init(id: UUID(uuidString: "E269ECA9-D085-46CD-9167-2CE1C52409DC")!, name: "hand soap", category: .cleaningSupplies, lifecycle: .permanent, consumable: .consumable, locker: .head, requiresDockside: false)
    }
    static var toiletBrush: PackableItemDefinition {
        .init(id: UUID(uuidString: "8669193A-EB67-4DFE-8DB8-368744C0F00D")!, name: "toilet brush", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .head, requiresDockside: false)
    }
    static var foxTail: PackableItemDefinition {
        .init(id: UUID(uuidString: "77F8740D-B356-43A4-88FC-038250D29A76")!, name: "fox tail", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var vacuum: PackableItemDefinition {
        .init(id: UUID(uuidString: "EC659BB2-0E34-4DE0-ABEB-BF8B2D14354F")!, name: "vacuum", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var oilSoakPadsDiapers: PackableItemDefinition {
        .init(id: UUID(uuidString: "9D3938E4-2598-4E4B-BF6C-B8BCE69BFFC6")!, name: "oil soak pads (diapers)", category: .cleaningSupplies, lifecycle: .permanent, consumable: .consumable, locker: .navTable, requiresDockside: false)
    }
    static var chamoisCloth: PackableItemDefinition {
        .init(id: UUID(uuidString: "B8D9D6DE-9802-4943-9F94-CB387149A86F")!, name: "chamois cloth", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var squeegee: PackableItemDefinition {
        .init(id: UUID(uuidString: "C244972B-9791-4109-8360-7E18F20F1398")!, name: "squeegee", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var broom: PackableItemDefinition {
        .init(id: UUID(uuidString: "AABF088A-A2CF-4D84-8229-E6F2E88E4B57")!, name: "broom", category: .cleaningSupplies, lifecycle: .permanent, consumable: nil, locker: .starboardSettee, requiresDockside: true)
    }
}
