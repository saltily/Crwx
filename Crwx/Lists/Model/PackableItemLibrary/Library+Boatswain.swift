//
//  Library+Boatswain.swift
//  Crwx
//
//  Created by Matthew Goacher on 8/1/26.
//

import Foundation

/// 48 items
/// Imported 8/1/2026, 12:54 pm
extension PackableItemDefinition {
    static var windlassHandle: PackableItemDefinition {
        .init(id: UUID(uuidString: "0BED7CB5-F80B-458D-9C77-E0BBC183A99F")!, name: "windlass handle", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .aftSettee, requiresDockside: false)
    }
    static var flags: PackableItemDefinition {
        .init(id: UUID(uuidString: "ABA523C1-7744-4A40-9B89-9DB5DB45A365")!, name: "flags", category: .boatswain, lifecycle: .permanent, consumable: .perishable, locker: .navTable, requiresDockside: false)
    }
    static var marline: PackableItemDefinition {
        .init(id: UUID(uuidString: "4E79FD00-57B7-46F8-A99A-EFF4D97DAB31")!, name: "marline", category: .boatswain, lifecycle: .permanent, consumable: .consumable, locker: .boatswainDrawer, requiresDockside: false)
    }
    static var seineTwine: PackableItemDefinition {
        .init(id: UUID(uuidString: "E8BEA885-EEDC-4D5F-A09F-874950AE3238")!, name: "seine twine", category: .boatswain, lifecycle: .permanent, consumable: .consumable, locker: .boatswainDrawer, requiresDockside: false)
    }
    static var whippingTwine: PackableItemDefinition {
        .init(id: UUID(uuidString: "86EEC72E-B3A3-45CE-B08E-4B3CC7FC5AAB")!, name: "whipping twine", category: .boatswain, lifecycle: .permanent, consumable: .consumable, locker: .boatswainDrawer, requiresDockside: false)
    }
    static var sailNeedles: PackableItemDefinition {
        .init(id: UUID(uuidString: "5164334A-5A2A-4024-A7E7-0402C45DB4E1")!, name: "sail needles", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .boatswainDrawer, requiresDockside: false)
    }
    static var sailPalm: PackableItemDefinition {
        .init(id: UUID(uuidString: "D1FEEDF1-6E54-4420-8AE9-3A44871D5050")!, name: "sail palm", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .boatswainDrawer, requiresDockside: false)
    }
    static var shackles: PackableItemDefinition {
        .init(id: UUID(uuidString: "AC9AD8DD-9A19-43EB-A891-1372EB8AF8C3")!, name: "shackles", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .boatswainDrawer, requiresDockside: false)
    }
    static var mousingWire: PackableItemDefinition {
        .init(id: UUID(uuidString: "958E7640-5576-403A-9938-B8112BDF1BFD")!, name: "mousing wire", category: .boatswain, lifecycle: .permanent, consumable: .consumable, locker: .boatswainDrawer, requiresDockside: false)
    }
    static var wireCutters: PackableItemDefinition {
        .init(id: UUID(uuidString: "03C9EA03-4F06-4EE6-B0F3-C4CC9B4AA838")!, name: "wire cutters", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .boatswainDrawer, requiresDockside: false)
    }
    static var antiSeize: PackableItemDefinition {
        .init(id: UUID(uuidString: "B7734103-D60F-4C4D-8AA8-EB08A3339264")!, name: "anti-seize", category: .boatswain, lifecycle: .permanent, consumable: .consumable, locker: .boatswainDrawer, requiresDockside: false)
    }
    static var divingMask: PackableItemDefinition {
        .init(id: UUID(uuidString: "E1DF4395-50F7-4D6F-9BAA-4095BF5BADFB")!, name: "diving mask", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .closets, requiresDockside: false)
    }
    static var snorkel: PackableItemDefinition {
        .init(id: UUID(uuidString: "AB1C9D3D-3803-42E4-8837-02129B5AFEBB")!, name: "snorkel", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .closets, requiresDockside: false)
    }
    static var wetsuit: PackableItemDefinition {
        .init(id: UUID(uuidString: "E871CC5A-A2DB-4CD7-9CD4-FC1818C1233A")!, name: "wetsuit", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .closets, requiresDockside: false)
    }
    static var weightBelt: PackableItemDefinition {
        .init(id: UUID(uuidString: "59BA11A3-6DD9-4A30-A0D3-B1D6143FC8E5")!, name: "weight belt", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .closets, requiresDockside: false)
    }
    static var fins: PackableItemDefinition {
        .init(id: UUID(uuidString: "50F108F3-C642-4C9B-98B6-B149EC753E2B")!, name: "fins", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .closets, requiresDockside: false)
    }
    static var underwaterGloves: PackableItemDefinition {
        .init(id: UUID(uuidString: "842F6148-55E4-4853-8635-B2659EAFF873")!, name: "underwater gloves", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .closets, requiresDockside: false)
    }
    static var spareRope: PackableItemDefinition {
        .init(id: UUID(uuidString: "05F5C4AC-077B-45B4-8080-3699B013F9A3")!, name: "spare rope", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: false)
    }
    static var smallStuff: PackableItemDefinition {
        .init(id: UUID(uuidString: "4FCDCC97-8642-483D-874F-4B114EC78A44")!, name: "small stuff", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: false)
    }
    static var spareLobsterBuoys: PackableItemDefinition {
        .init(id: UUID(uuidString: "A60914BD-E62C-47FE-BB83-F0785E902483")!, name: "spare lobster buoys", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: false)
    }
    static var fenders: PackableItemDefinition {
        .init(id: UUID(uuidString: "863B53EB-A0AA-432A-95AC-58CB63EA8835")!, name: "fenders", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: false)
    }
    static var twoAnchors: PackableItemDefinition {
        .init(id: UUID(uuidString: "21B8612E-8FA5-49CF-9F6B-F5A4B70580CB")!, name: "two anchors", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: true)
    }
    static var dinghyOffhaulAndLongRope: PackableItemDefinition {
        .init(id: UUID(uuidString: "241D200F-D612-4A10-AEB4-FF9B5E0E8F4B")!, name: "dinghy offhaul and long rope", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: false)
    }
    static var boardingLadder: PackableItemDefinition {
        .init(id: UUID(uuidString: "EF2E71EF-0ED0-4054-B60E-C54F46058E58")!, name: "boarding ladder", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: true)
    }
    static var boatswainsChair: PackableItemDefinition {
        .init(id: UUID(uuidString: "7354313F-A287-4123-939B-8AA2773F9133")!, name: "boatswain’s chair", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .cockpit, requiresDockside: false)
    }
    static var knife: PackableItemDefinition {
        .init(id: UUID(uuidString: "AA21DFB1-B674-4127-ACD4-F18F3F4D0E42")!, name: "knife", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var gerberTool: PackableItemDefinition {
        .init(id: UUID(uuidString: "F6F04683-7B84-4C84-8A2C-EE5C4DDB880B")!, name: "gerber tool", category: .boatswain, lifecycle: .daysail, consumable: nil, locker: .navTable, requiresDockside: false)
    }
    static var boatHook: PackableItemDefinition {
        .init(id: UUID(uuidString: "FC827414-B94B-4D14-8CD5-E31979D814A9")!, name: "boat hook", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .onDeck, requiresDockside: true)
    }
    static var winchHandles: PackableItemDefinition {
        .init(id: UUID(uuidString: "CC5E4253-562F-4599-83AF-DA7DCDE076D4")!, name: "winch handles", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .onDeck, requiresDockside: false)
    }
    static var boomCrutch: PackableItemDefinition {
        .init(id: UUID(uuidString: "90E44962-5E9A-43AB-B591-B3E082BE643D")!, name: "boom crutch", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .onDeck, requiresDockside: true)
    }
    static var davits: PackableItemDefinition {
        .init(id: UUID(uuidString: "53C17441-7ECB-4F92-AF9D-30BDE72BFDB9")!, name: "davits", category: .boatswain, lifecycle: .seasonal, consumable: nil, locker: .onDeck, requiresDockside: true)
    }
    static var stanchions: PackableItemDefinition {
        .init(id: UUID(uuidString: "E67F5C4A-B8B5-455B-8463-D1C2D9AB8089")!, name: "stanchions", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .onDeck, requiresDockside: false)
    }
    static var lifelines: PackableItemDefinition {
        .init(id: UUID(uuidString: "4DAA80E2-A624-46A7-A726-05ECA7DCD21E")!, name: "lifelines", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .onDeck, requiresDockside: false)
    }
    static var mainSheet: PackableItemDefinition {
        .init(id: UUID(uuidString: "D647ED8B-C0A8-4B74-A4BF-CC6DB777D4CD")!, name: "main sheet", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .onDeck, requiresDockside: false)
    }
    static var mainHalyardBlocks: PackableItemDefinition {
        .init(id: UUID(uuidString: "7A097428-D2FB-42EE-9C4C-7FCF5AB4EF39")!, name: "main halyard & blocks", category: .boatswain, lifecycle: .seasonal, consumable: nil, locker: .onDeck, requiresDockside: false)
    }
    static var lazyjacks: PackableItemDefinition {
        .init(id: UUID(uuidString: "5090BAC6-AE00-4316-B9D8-1452FED20CD6")!, name: "lazyjacks", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .onDeck, requiresDockside: false)
    }
    static var flagHalyards: PackableItemDefinition {
        .init(id: UUID(uuidString: "1C22263F-3FD5-41BA-AB74-88D0C2584734")!, name: "flag halyards", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .onDeck, requiresDockside: false)
    }
    static var screens: PackableItemDefinition {
        .init(id: UUID(uuidString: "58ACC9DA-CDF1-4E43-A8B4-7A26458A3EB6")!, name: "screens", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .onDeck, requiresDockside: false)
    }
    static var clevisPins: PackableItemDefinition {
        .init(id: UUID(uuidString: "D8B57E85-4D82-47B3-B3AB-C00DB20CCAF9")!, name: "clevis pins", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .portBookshelf, requiresDockside: false)
    }
    static var cotterPins: PackableItemDefinition {
        .init(id: UUID(uuidString: "763E672D-E22B-4530-B567-4288446791A2")!, name: "cotter pins", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .portBookshelf, requiresDockside: false)
    }
    static var cotterRings: PackableItemDefinition {
        .init(id: UUID(uuidString: "0BD56331-094B-4CDF-BDA1-CE58C74E10DD")!, name: "cotter rings", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .portBookshelf, requiresDockside: false)
    }
    static var fiftyTwoHundred: PackableItemDefinition {
        .init(id: UUID(uuidString: "A85593B0-30E9-4138-9BD2-0729DC8D41F7")!, name: "5200", category: .boatswain, lifecycle: .permanent, consumable: .consumable, locker: .portTable, requiresDockside: false)
    }
    static var liquidWeld: PackableItemDefinition {
        .init(id: UUID(uuidString: "D8DB5E31-3A1F-437D-936A-D124387EFFD8")!, name: "liquid weld", category: .boatswain, lifecycle: .permanent, consumable: .consumable, locker: .portTable, requiresDockside: false)
    }
    static var patchingMaterialsTapesAndLumber: PackableItemDefinition {
        .init(id: UUID(uuidString: "AAD283DF-F90C-4823-AE46-C81F337C00B1")!, name: "patching materials (tapes and lumber)", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .portTable, requiresDockside: false)
    }
    static var woodenPlugs: PackableItemDefinition {
        .init(id: UUID(uuidString: "0B7075A8-78EB-4893-B1F2-35394865AF2B")!, name: "wooden plugs", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .portTable, requiresDockside: false)
    }
    static var drogue: PackableItemDefinition {
        .init(id: UUID(uuidString: "14F32E65-8AB0-420F-B231-4E05B90AB5AA")!, name: "drogue", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .veeBerth, requiresDockside: false)
    }
    static var dinghyBailer: PackableItemDefinition {
        .init(id: UUID(uuidString: "997F7135-ED27-415A-9A7C-1D5D4CA3F047")!, name: "dinghy bailer", category: .boatswain, lifecycle: .cruise, consumable: nil, locker: .onDeck, requiresDockside: false)
    }
    static var sailTies: PackableItemDefinition {
        .init(id: UUID(uuidString: "E8139AEB-6B68-4CD5-BD86-E548D2E0F8EA")!, name: "sail ties", category: .boatswain, lifecycle: .permanent, consumable: nil, locker: .onDeck, requiresDockside: false)
    }
}
