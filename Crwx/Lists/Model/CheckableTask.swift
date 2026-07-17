//
//  CheckableTask.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import Foundation

/// This is likely to replace the ``TaskItemViewModel``.  Starting with this as something to help me play around with checklist interface as an initial starting point for brainstorming stuff that might go into checklists.  Mutable in some ways, but not persistent yet.
///
/// I want these to have a stable id that is not dependent on the label (which could be duplicate) so that it can track for reordering and such.
@Observable
final class CheckableTask: Identifiable, Codable, Sendable {
    let id: UUID
    var label: String
    var action: TaskAction?
    var checkedOff: Date?
    /// So I know what type of form to display for it, whether it has nested steps and/or packing items.
    var style: S = .plain
    var packingList: [PackableItem] = []
    var steps: [CheckableTask] = []
    init(_ label: String, action: TaskAction? = nil, checkedOff: Date? = nil, style: S = .plain, id: UUID = .init(), packingList: [PackableItem] = [], steps: [CheckableTask] = []) {
        self.id = id
        self.label = label
        self.action = action
        self.checkedOff = checkedOff
        self.style = style
        self.packingList = packingList
        self.steps = steps
    }
}

extension CheckableTask: ExpressibleByStringLiteral {
    convenience init(stringLiteral value: String) {
        self.init(value)
    }
    var isChecked: Bool {
        get { checkedOff != nil }
        set {
            guard newValue != isChecked else { return }
            checkedOff = newValue ? .now : nil
        }
    }
}


// MARK: Hashable
extension CheckableTask: Hashable {
    static func == (lhs: CheckableTask, rhs: CheckableTask) -> Bool {
        lhs.id == rhs.id &&
        lhs.label == rhs.label &&
        lhs.action == rhs.action &&
        lhs.checkedOff == rhs.checkedOff &&
        lhs.style == rhs.style &&
        lhs.packingList == rhs.packingList &&
        lhs.steps == rhs.steps
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(label)
        hasher.combine(action)
        hasher.combine(checkedOff)
        hasher.combine(style)
        hasher.combine(packingList)
        hasher.combine(steps)
    }
}


// MARK: Style
extension CheckableTask {
    enum S: Int, Codable, Sendable, CaseIterable, Identifiable {
        case plain, packing, project
        var id: Int { rawValue }
        var systemImage: String {
            switch self {
            case .plain:
                "text.justify.left"
            case .project:
                "list.bullet.indent"
            case .packing:
                "shippingbox"
            }
        }
    }
}


// MARK: - General Packing, Purchase, Inventory
extension CheckableTask {
    
    
    // MARK: Daysail
    static var daysailPreConfirm: CheckableTask {
        .confirm([
            .snacks,
            .drinks,
            .gerber,
            .init("pfd count", .init(locker: .cockpit, category: .safetyEquipment, requiresDockside: false, lifecycles: [])),
            .init("hats", .init(locker: .navTable, category: .outerwear, requiresDockside: false, lifecycles: [.seasonal])),
            .init("jackets", .init(locker: .aftSettee, category: .outerwear, requiresDockside: false, lifecycles: [.seasonal]))
        ])
//        .confirm("snacks, drinks, gerber multi-tool, pfd count, hats, jackets")
    }
    static var daysailPostConfirm: CheckableTask {
        .confirm([
            .snacks,
            .drinks
        ], prefix: "Update inventory")
//        .confirm("snacks, drinks", prefix: "Update inventory")
    }
    static var daysailPack: CheckableTask {
        .pack("sunglasses, muck boots")
    }
    
    // MARK: Cruise
    static var cruisePreConfirm: CheckableTask {
        // I should give these ids and the ones I'm reusing should have stable fixed ids
        .confirm([
            .snacks,
            .drinks,
            .init("outerwear", .init(locker: .aftSettee, category: .outerwear, requiresDockside: false, lifecycles: [.seasonal])),
            .init("trash bags", .init(locker: .galley, category: .cleaningSupplies, requiresDockside: false, lifecycles: [.consumable])),
            .cleaningSupplies,
            .init("linens", .init(locker: .veeBerth, category: .linens, requiresDockside: false, lifecycles: [.seasonal])),
            .gerber,
            .init("safety equipment", .init(locker: .aftSettee, category: .safetyEquipment, requiresDockside: false, lifecycles: [])),
            .init("propane", .init(locker: .galley, category: .energy, requiresDockside: false, lifecycles: [.consumable])),
            .init("fuel", .init(locker: .onDeck, category: .energy, requiresDockside: false, lifecycles: [.consumable])),
            .toiletPaper,
            .paperTowels
        ])
//        .confirm("snacks, drinks, outerwear, trash bags, cleaning supplies, linens, gerber multi-tool, safety equipment, propane, fuel, toilet paper, paper towels")
    }
    static var cruisePostConfirm: CheckableTask {
        .confirm([
            .snacks,
            .drinks,
            .cleaningSupplies,
            .toiletPaper,
            .paperTowels
        ], prefix: "Update inventory")
//        .confirm("snacks, drinks, cleaning supplies, toilet paper, paper towel", prefix: "Update inventory")
    }
    static var cruisePackFood: CheckableTask {
        .pack("food")
    }
    static var cruisePackPersonal: CheckableTask {
        .pack("clothing, toiletries, devices and chargers (watch battery pack), muck boots, sunglasses, reading materials, instruments")
    }
    static var cruisePackChainsaw: CheckableTask {
        .pack("chainsaw")
    }
    static var cruiseCleanup: CheckableTask {
        .pack("ice, trash, linens, dehumidifiers, empty water jugs, white dinghy, chainsaw", prefix: "Go back for")
    }
    
    // MARK: Spring
    static var fitoutPurchase: CheckableTask {
        .purchase("flags, flares, mooring shcakle, house batteries, starter batteries, alkaline batteries, dock boards")
    }
    static var fitoutBringHome: CheckableTask {
        .pack("shrink wrap ropes, framing", prefix: "Bring home")
    }
    static var fitoutTakeOver: CheckableTask {
        .pack("pressure washer, garden hoses, extension cords, bilge diapers, fibreglass repair, welding machine, water heater, grinder and sander", prefix: "Take over")
    }
    static var enginePurchase: CheckableTask {
        .purchase("engine filters, engine oil, coolant, diesel")
    }
    static var hullPurchase: CheckableTask {
        .purchase("bottom paint, larger rollers, Frank's red hot, 2-inch chip brushes, nitrile gloves, 2-inch painter's tape, green paint, small rollers, clear coat, garden sprayer, foam rollers, stern lettering, fibreglass primer")
    }
    
    // MARK: Fall
    static var layupPurchase: CheckableTask {
        .purchase("2 gals RV antifreeze")
    }
    static var shrinkWrapPurchase: CheckableTask {
        .purchase("shrink wrap, shrink wrap tape, 20lb propane refill")
    }
    static var winterPurchase: CheckableTask {
        .purchase("red ensign flag materials, mooring rope, furler tracks if necessary")
    }
}


// MARK: Shortcut Builders
extension CheckableTask {
    fileprivate static func confirm(_ tuples: [PackingListTuple], prefix: String = "Confirm") -> CheckableTask {
        let state = PackableItem.State(status: .loadedOnBoat, due: .never)
        let items: [PackableItem] = tuples.map {
            PackableItem(id: .init(), label: $0.string, state: state, configuration: $0.configuration)
        }
        return .packing("\(prefix):", items: items, action: .confirm)
    }
    static func confirm(_ itemList: String, prefix: String = "Confirm") -> CheckableTask {
        let itemStrings = itemList.components(separatedBy: ", ")
        let items: [PackableItem] = itemStrings.map {
            PackableItem($0)
        }
        return .packing("\(prefix): \(items.map(\.label).joined(separator: ", ")).", items: items, action: .confirm)
    }
    static func purchase(_ itemList: String) -> CheckableTask {
        let itemStrings = itemList.components(separatedBy: ", ")
        let items: [PackableItem] = itemStrings.map {
            PackableItem($0)
        }
        return .packing("Purchase: \(items.map(\.label).joined(separator: ", ")).", items: items)
    }
    static func pack(_ itemList: String, prefix: String = "Pack") -> CheckableTask {
        let itemStrings = itemList.components(separatedBy: ", ")
        let items: [PackableItem] = itemStrings.map {
            PackableItem($0)
        }
        return .packing("\(prefix): \(items.map(\.label).joined(separator: ", ")).", items: items)
    }
    static func packing(_ label: String, items: [PackableItem], action: TaskAction = .pack) -> CheckableTask {
        .init(label, action: action, style: .packing, packingList: items)
    }
}
fileprivate struct PackingListTuple {
    init(_ string: String, _ configuration: PackableItem.Configuration, _ id: UUID = .init()) {
        self.string = string
        self.configuration = configuration
        self.id = id
    }
    let string: String
    let configuration: PackableItem.Configuration
    let id: UUID
}
extension PackingListTuple {
    static var snacks: Self {
        .init("snacks", .init(locker: .galley, category: .food, requiresDockside: false, lifecycles: [.consumable, .seasonal]), .init(uuidString: "d61f09cf-8420-4378-8d71-de14a2e1f9ed")!)
    }
    static var drinks: Self {
        .init("drinks", .init(locker: .starboardBookshelf, category: .drinks, requiresDockside: false, lifecycles: [.consumable, .seasonal]), .init(uuidString: "62677871-00e5-4279-9ed6-a01b53948492")!)
    }
    static var gerber: Self {
        .init("gerber multi-tool", .init(locker: .navTable, category: .tools, requiresDockside: false, lifecycles: [.seasonal]), .init(uuidString: "cc7f9df7-2ffb-4312-a4e3-f86fb7c00d8c")!)
    }
    static var cleaningSupplies: Self {
        .init("cleaning supplies", .init(locker: .head, category: .cleaningSupplies, requiresDockside: false, lifecycles: [.consumable]), .init(uuidString: "6cfa3307-b982-4a8c-8f71-7eb168e84484")!)
    }
    static var toiletPaper: Self {
        .init("toilet paper", .init(locker: .head, category: .paperProducts, requiresDockside: false, lifecycles: [.consumable, .seasonal]), .init(uuidString: "c92ab410-1d21-4738-8ae6-42147b22deb9")!)
    }
    static var paperTowels: Self {
        .init("paper towels", .init(locker: .closets, category: .paperProducts, requiresDockside: false, lifecycles: [.consumable, .seasonal]), .init(uuidString: "76afe56d-bf1a-4edd-83a4-983724504743")!)
    }
}


// MARK: Previews
extension CheckableTask {
    static var plain: CheckableTask {
        "Do this one thing."
    }
    static var packing: CheckableTask {
        .init("Pack these things.", style: .packing, packingList: [
            "clear coat",
            "garden sprayer",
            "foam roller",
            "nitrile gloves",
            "step ladder"
        ])
    }
    static var project: CheckableTask {
        .init("Clear coat hull.", style: .project, packingList: [
            "clear coat",
            "garden sprayer",
            "foam roller",
            "nitrile gloves",
            "step ladder"
        ], steps: [
            "Fill garden sprayer with clear coat.",
            "Setup ladder, gloves, and foam roller.",
            "Spray a section, then roll out with roller.",
            "Repeat until finished.",
            "Reclaim unused clear coat.",
            "Discard used sprayer, gloves, and roller cover."
        ])
    }
}
