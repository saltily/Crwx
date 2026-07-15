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
        .init("Confirm: snacks, drinks, gerber multi-tool, pfd count, hats and jackets.", action: .daysailConfirm)
    }
    static var daysailPostConfirm: CheckableTask {
        .init("Update inventory: snacks, drinks.", action: .daysailPostConfirm)
    }
    static var daysailPack: CheckableTask {
        .init("Pack: sunglasses, muck boots.", action: .daysailPack)
    }
    
    // MARK: Cruise
    static var cruisePreConfirm: CheckableTask {
        .init("Confirm inventory: snacks, drinks, outerwear, trash bags, cleaning supplies, linens, gerber multi-tool, safety equipment, propane, fuel, toilet paper, paper towels.", action: .cruiseConfirm)
    }
    static var cruisePostConfirm: CheckableTask {
        .init("Update inventory: snacks, drinks, cleaning supplies, toilet paper, paper towel.", action: .cruisePostConfirm)
    }
    static var cruisePackFood: CheckableTask {
        .init("Pack food.", action: .cruiseFood)
    }
    static var cruisePackPersonal: CheckableTask {
        .init("Pack: clothing, toiletries, devices and chargers (watch battery pack), muck boots, sunglasses, reading materials, instruments.", action: .cruisePersonal)
    }
    static var cruisePackChainsaw: CheckableTask {
        .init("Pack chainsaw.", action: .cruiseChainsaw)
    }
    static var cruiseCleanup: CheckableTask {
        .init("Go back for ice, trash, linens, dehumidifiers, empty water jugs, white dinghy, chainsaw.", action: .cruiseCleanup)
    }
    
    // MARK: Spring
    static var fitoutPurchase: CheckableTask {
        "Purchase: flags, flares, mooring shackle, house batteries, starter batteries, alkaline batteries, dock boards."
    }
    static var fitoutBringHome: CheckableTask {
        "Bring home: shrink wrap ropes and framing."
    }
    static var fitoutTakeOver: CheckableTask {
        "Take over: pressure washer, garden hoses, extension cords, bilge diapers, fibreglass repair, welding machine, water heater, grinder and sander."
    }
    static var enginePurchase: CheckableTask {
        "Purchase: engine filters, engine oil, coolant, diesel."
    }
    static var hullPurchase: CheckableTask {
        "Purchase: bottom paint, large rollers, Frank's red hot, 2-inch chip brushes, nitrile gloves, 2-inch painter's tape, green paint, small rollers, clear coat, garden sprayer, foam rollers, stern lettering, fibreglass primer."
    }
    
    // MARK: Fall
    static var layupPurchase: CheckableTask {
        "Purchase: 2 gals RV antifreeze."
    }
    static var shrinkWrapPurchase: CheckableTask {
        "Purchase: shrink wrap, shrink wrap tape, propane."
    }
    static var winterPurchase: CheckableTask {
        "Purchase: red ensign flag materials, mooring rope, furler tracks if necessary."
    }
}


// MARK: Shortcut Builders
extension CheckableTask {
    /// Basic idea being that I can establish verbs and then a list of packable items to build these.
    /// Maybe even like:
    /// ```swift
    /// .confirm {
    ///     "maple syrup"
    ///     "flour"
    /// }
    /// ```
    static func confirm(_ items: [String]) -> CheckableTask {
        .init(stringLiteral: "Confirm inventory: \(items.formatted(.list(type: .and)))")
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
        .init("Clear coat hull.", style: .packing, packingList: [
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
