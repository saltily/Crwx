//
//  PackableItemDefinition.swift
//  Crwx
//
//  Created by Matthew Goacher on 8/1/26.
//

import Foundation
import CodableSalt
import FoundationSalt

/// This is to help me hardcode a collection built from a spreadsheet with fixed stable identifiers.
///
/// Now I should be able to do `let parsed: [PackableItemDefinition] = try .init(tsv: pasteboardString)`
struct PackableItemDefinition: CsvDecodable {
    let id: UUID
    let name: String
    let category: PackedCategory
    let lifecycle: PackedLifecycle
    let consumable: PackedLifecycle?
    let locker: StorageLocker
    let requiresDockside: Bool
}


extension PackableItemDefinition {
    enum Key: CodingKey {
        case id, name, category, lifecycle, consumable, locker, requiresDockside
    }
    init?(from decoder: CsvDecoder<Key>) throws {
        self.id = .init()
        self.name = try decoder.decode(.name)
        self.category = .init(rawValue: try decoder.decode(.category))
        guard !self.category.isCustom
        else { throw E.unknownCategory(self.category.rawValue) }
        let lifecycleString = try decoder.decode(.lifecycle)
        guard let lifecycle = PackedLifecycle(rawValue: lifecycleString)
        else { throw E.unknownLifecycle(lifecycleString) }
        self.lifecycle = lifecycle
        if let consumableString = try? decoder.decode(.consumable).nilIfEmpty {
            guard let consumable = PackedLifecycle(rawValue: consumableString)
            else { throw E.unknownLifecycle(consumableString) }
            self.consumable = consumable
        } else {
            self.consumable = nil
        }
        let lockerString = try decoder.decode(.locker)
        guard let locker = StorageLocker(rawValue: lockerString)
        else { throw E.unknownLocker(lockerString) }
        self.locker = locker
        let boolString = try decoder.decode(.requiresDockside)
        switch boolString.lowercased() {
        case "false": self.requiresDockside = false
        case "true": self.requiresDockside = true
        default: throw E.unknownBoolean(boolString)
        }
    }
    enum E: Error {
        case unknownCategory(String)
        case unknownLifecycle(String)
        case unknownLocker(String)
        case unknownBoolean(String)
    }
}


extension PackableItemDefinition {
    static var allCases: [PackableItemDefinition] {
        [
            // Boatswain
            .windlassHandle, .flags, .marline, .seineTwine, .whippingTwine, .sailNeedles, .sailPalm, .shackles, .mousingWire, .wireCutters, .antiSeize, .divingMask, .snorkel, .wetsuit, .weightBelt, .fins, .underwaterGloves, .spareRope, .smallStuff, .spareLobsterBuoys, .fenders, .twoAnchors, .dinghyOffhaulAndLongRope, .boardingLadder, .boatswainsChair, .knife, .gerberTool, .boatHook, .winchHandles, .boomCrutch, .davits, .stanchions, .lifelines, .mainSheet, .mainHalyardBlocks, .lazyjacks, .flagHalyards, .screens, .clevisPins, .cotterPins, .cotterRings, .fiftyTwoHundred, .liquidWeld, .patchingMaterialsTapesAndLumber, .woodenPlugs, .drogue, .dinghyBailer, .sailTies
        ]
    }
}
