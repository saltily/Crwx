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
        .confirm("snacks, drinks, gerber multi-tool, pfd count, hats, jackets")
    }
    static var daysailPostConfirm: CheckableTask {
        .confirm("snacks, drinks", prefix: "Update inventory")
    }
    static var daysailPack: CheckableTask {
        .pack("sunglasses, muck boots")
    }
    
    // MARK: Cruise
    static var cruisePreConfirm: CheckableTask {
        .confirm("snacks, drinks, outerwear, trash bags, cleaning supplies, linens, gerber multi-tool, safety equipment, propane, fuel, toilet paper, paper towels")
    }
    static var cruisePostConfirm: CheckableTask {
        .confirm("snacks, drinks, cleaning supplies, toilet paper, paper towel", prefix: "Update inventory")
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
