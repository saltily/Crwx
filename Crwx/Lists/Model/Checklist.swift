//
//  Checklist.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/28/26.
//

import Foundation

/// Pre-defined for certain kinds of tasks so I can adjust their definition in one place, regardless of how many instances, and they'll always stay the same.
enum Checklist: String, Codable, Sendable, Equatable {
    case springFitOut, springLaunch, springUprig, springLoading
    case vesselInventory, safetyEquipment
    case daysailPredeparture, daysailPostarrival
    case cruisePredeparture, cruisePostarrival
    case anchoragePrearrival, anchoragePostarrival, anchoragePredeparture, anchoragePostdeparture
    case fallOffloading, fallDownrig, fallHaulout, fallLayup
    case winterMaintenance
}

// MARK: Label
extension Checklist {
    var label: String {
        switch self {
        case .springFitOut: "Spring Fit-Out"
        case .springLaunch: "Spring Launch"
        case .springUprig: "Spring Uprig"
        case .springLoading: "Spring Loading"
        case .vesselInventory: "Vessel Inventory"
        case .safetyEquipment: "Safety Equipment"
        case .daysailPredeparture: "Daysail Pre-Departure"
        case .daysailPostarrival: "Daysail Post-Arrival"
        case .cruisePredeparture: "Cruise Pre-Departure"
        case .cruisePostarrival: "Cruise Post-Arrival"
        case .anchoragePrearrival: "Anchorage Pre-Arrival"
        case .anchoragePostarrival: "Anchorage Post-Arrival"
        case .anchoragePredeparture: "Anchorage Pre-Departure"
        case .anchoragePostdeparture: "Anchorage Post-Departure"
        case .fallOffloading: "Fall Offloading"
        case .fallDownrig: "Fall Downrig"
        case .fallHaulout: "Fall Haulout"
        case .fallLayup: "Fall Layup"
        case .winterMaintenance: "Winter Maintenance"
        }
    }
}

// MARK: Steps
extension Checklist {
    var steps: [TaskItemViewModel] {
        switch self {
            // MARK: Other
        case .safetyEquipment: [
            "Flares",
            "Life Ring",
            "PFDs",
            "Oil Placard",
            "Garbage Placard",
            "Registration",
            "MSD Holding Tank",
            "Fire Extinguishers",
            "Horn",
            "Nav Lights"
        ]
        case .vesselInventory: [
            .init("Permanent Inventory", [
                .init("Boatswain", [
                    "Knife",
                    "Spare rope, small stuﬀ, marlin, seine twine, whipping twine, sail needles, sail palm.",
                    "Spare lobster buoys for marking.",
                    "Fenders.",
                    "Boat hooks.",
                    "Winch handles.",
                    "Windlass handle.",
                    "Anchors",
                    "Shackles, mousing wire, wire cutters, anti-seize, clevis pins, cotter pins, cotter rings.",
                    "Boarding ladder.",
                    "Mask / snorkel / wetsuit / weight belt / fins / underwater gloves, knife, flashlights.",
                    "5200 / liquid weld / patching materials (tapes and lumber) / plugs.",
                    "Drogue (sea anchor).",
                    "Flags."
                ]),
                .init("Safety", [
                    "Life jackets.",
                    "Throw ring.",
                    "Flares / ditch kit.",
                    "Whitle / horn / bell.",
                    "Fire extinguishers.",
                    "Hearing protectors."
                ]),
                .init("Navigation", [
                    "GPS.",
                    "Depth sounder.",
                    "Compass.",
                    "Binoculars.",
                    "Plotting tools, pencil, sharpener, eraser, dividers, triangles.",
                    "Radios.",
                    "Charts.",
                    "Flashlights.",
                    "Light bulbs.",
                    "Anchor day shape."
                ]),
                .init("Steward", [
                    "Playing cards.",
                    "Lanterns.",
                    "Frying pan / percolator / sauce pan."
                ])
            ])
        ]
            // MARK: Spring
        case .springFitOut: [
            "Remove shrink wrap.",
            "New flags.",
            .init("Prep engine.", [
                "Charge batteries.",
                "Restock engine fluids and filter inventory.",
                "Add fuel.",
                "Oil change.",
                "Change fuel filters.",
                "Install batteries.",
                "Run engine."
            ]),
            "Registration stickers.",
            .init("Green dinghy.", [
                "Charge batteries."
            ]),
            .init("Dock.", [
                "Put out offhaul."
            ])
        ]
        case .springLaunch: [
            "Dinghy.",
            "Mooring.",
            "Stage vehicle.",
            "Lashed for road.",
            "Ladder",
            "Run engine once again.",
            "Confirm GPS.",
            "Schedule."
        ]
        case .springUprig: [
            .init("Prep mast.", [
                "Install main halyard aloft.",
                "Mast lashings removed, lifting strap in place.",
                "Secure furler foot near bow.",
                "Davits removed and left ashore."
            ]),
            "Plan to arrive Bucks Harbour between half tide and hour before/after low. Plan for 1-2 hours transit."
        ]
            // MARK: Fall
        case .fallLayup: [
            "Antifreeze toilet, engine, bilge.",
            "Offload water heater.",
            "Disconnect propane bottles.",
            "Close fuel valves.",
            "Drain racor.",
            "Stow cushions in vee berth with dryer sheets.",
            "Stow sails, linens, paper products in closets with dryer sheets.",
            "Offload trash, fleece, slicker, VHF, GPS, flashlight, charts.",
            "Close sea cocks except cockpit and sink drains.",
            .init("Shrink wrap.", [
                
            ]),
            .init("Dock", [
                "Bring in offhaul, install chain marker and buoy. Best to unreeve at high tide so clean."
            ]),
            .init("Dinghies", [
                "Stow batteries in shop.",
                "Stow oar locks in shop.",
                "Stow trolling motor in garden space."
            ])
        ]
        case .winterMaintenance: [
            .init("Update library.", [
                "Chart updates.",
                "Coast pilot.",
                "Light list.",
                "Tide tables.",
                "Tidal current tables."
            ]),
            "Rebuild main halyard blocks.",
            "Sew new red ensign."
        ]
        default: []
        }
    }
}


// MARK: Daysail
extension Checklist {
    var viewModel: ChecklistViewModel {
        switch self {
        case .daysailPredeparture:
            [
                "Weather and tide confirmed.",
                "Log pre-departure with marine forecast and passenger list.",
                "Confirm: snacks, drinks, gerber multi-tool, pfd count, hats and jackets.", // this could involve scanning the inventory and adding stuff to bring out
                "Pack: sunglasses, muck boots.", // this could involve scanning the inventory and adding stuff to bring out
                "Check engine.",
                "Turn on breakers.",
                "Pass up pillows, navigation basket, and GPS.",
                "Boot up GPS.",
                "Start engine.",
                "Prep mainsail.",
                "Prep jib.",
                "Adjust flags or bimini.",
                "Secure dinghy and lifelines.",
                "Observe wind and tide and log depart.",
                "Raise mainsail if appropriate.",
                "Cast off mooring."
            ]
        default: []
        }
    }
}
