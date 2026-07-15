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
    case daysailPredeparture, daysailPostarrival
    case cruisePredeparture, cruisePostarrival
    case anchoragePrearrival, anchoragePostarrival, anchoragePredeparture, anchoragePostdeparture
    case fallOffloading, fallDownrig, fallHaulout, fallLayup
    case winterMaintenance
}

//// MARK: Label
//extension Checklist {
//    var label: String {
//        switch self {
//        case .springFitOut: "Spring Fit-Out"
//        case .springLaunch: "Spring Launch"
//        case .springUprig: "Spring Uprig"
//        case .springLoading: "Spring Loading"
//        case .daysailPredeparture: "Daysail Pre-Departure"
//        case .daysailPostarrival: "Daysail Post-Arrival"
//        case .cruisePredeparture: "Cruise Pre-Departure"
//        case .cruisePostarrival: "Cruise Post-Arrival"
//        case .anchoragePrearrival: "Anchorage Pre-Arrival"
//        case .anchoragePostarrival: "Anchorage Post-Arrival"
//        case .anchoragePredeparture: "Anchorage Pre-Departure"
//        case .anchoragePostdeparture: "Anchorage Post-Departure"
//        case .fallOffloading: "Fall Offloading"
//        case .fallDownrig: "Fall Downrig"
//        case .fallHaulout: "Fall Haulout"
//        case .fallLayup: "Fall Layup"
//        case .winterMaintenance: "Winter Maintenance"
//        }
//    }
//}

//// MARK: Steps
//extension Checklist {
//    var steps: [TaskItemViewModel] {
//        switch self {
//            // MARK: Other
//        case .safetyEquipment: [
//            "Flares",
//            "Life Ring",
//            "PFDs",
//            "Oil Placard",
//            "Garbage Placard",
//            "Registration",
//            "MSD Holding Tank",
//            "Fire Extinguishers",
//            "Horn",
//            "Nav Lights"
//        ]
//        case .vesselInventory: [
//            .init("Permanent Inventory", [
//                .init("Boatswain", [
//                    "Knife",
//                    "Spare rope, small stuﬀ, marlin, seine twine, whipping twine, sail needles, sail palm.",
//                    "Spare lobster buoys for marking.",
//                    "Fenders.",
//                    "Boat hooks.",
//                    "Winch handles.",
//                    "Windlass handle.",
//                    "Anchors",
//                    "Shackles, mousing wire, wire cutters, anti-seize, clevis pins, cotter pins, cotter rings.",
//                    "Boarding ladder.",
//                    "Mask / snorkel / wetsuit / weight belt / fins / underwater gloves, knife, flashlights.",
//                    "5200 / liquid weld / patching materials (tapes and lumber) / plugs.",
//                    "Drogue (sea anchor).",
//                    "Flags."
//                ]),
//                .init("Safety", [
//                    "Life jackets.",
//                    "Throw ring.",
//                    "Flares / ditch kit.",
//                    "Whitle / horn / bell.",
//                    "Fire extinguishers.",
//                    "Hearing protectors."
//                ]),
//                .init("Navigation", [
//                    "GPS.",
//                    "Depth sounder.",
//                    "Compass.",
//                    "Binoculars.",
//                    "Plotting tools, pencil, sharpener, eraser, dividers, triangles.",
//                    "Radios.",
//                    "Charts.",
//                    "Flashlights.",
//                    "Light bulbs.",
//                    "Anchor day shape."
//                ]),
//                .init("Steward", [
//                    "Playing cards.",
//                    "Lanterns.",
//                    "Frying pan / percolator / sauce pan."
//                ])
//            ])
//        ]
//            // MARK: Spring
//        case .springFitOut: [
//            "Remove shrink wrap.",
//            "New flags.",
//            .init("Prep engine.", [
//                "Charge batteries.",
//                "Restock engine fluids and filter inventory.",
//                "Add fuel.",
//                "Oil change.",
//                "Change fuel filters.",
//                "Install batteries.",
//                "Run engine."
//            ]),
//            "Registration stickers.",
//            .init("Green dinghy.", [
//                "Charge batteries."
//            ]),
//            .init("Dock.", [
//                "Put out offhaul."
//            ])
//        ]
//        case .springLaunch: [
//            "Dinghy.",
//            "Mooring.",
//            "Stage vehicle.",
//            "Lashed for road.",
//            "Ladder",
//            "Run engine once again.",
//            "Confirm GPS.",
//            "Schedule."
//        ]
//        case .springUprig: [
//            .init("Prep mast.", [
//                "Install main halyard aloft.",
//                "Mast lashings removed, lifting strap in place.",
//                "Secure furler foot near bow.",
//                "Davits removed and left ashore."
//            ]),
//            "Plan to arrive Bucks Harbour between half tide and hour before/after low. Plan for 1-2 hours transit."
//        ]
//            // MARK: Fall
//        case .fallLayup: [
//            "Antifreeze toilet, engine, bilge.",
//            "Offload water heater.",
//            "Disconnect propane bottles.",
//            "Close fuel valves.",
//            "Drain racor.",
//            "Stow cushions in vee berth with dryer sheets.",
//            "Stow sails, linens, paper products in closets with dryer sheets.",
//            "Offload trash, fleece, slicker, VHF, GPS, flashlight, charts.",
//            "Close sea cocks except cockpit and sink drains.",
//            .init("Shrink wrap.", [
//                
//            ]),
//            .init("Dock", [
//                "Bring in offhaul, install chain marker and buoy. Best to unreeve at high tide so clean."
//            ]),
//            .init("Dinghies", [
//                "Stow batteries in shop.",
//                "Stow oar locks in shop.",
//                "Stow trolling motor in garden space."
//            ])
//        ]
//        case .winterMaintenance: [
//            .init("Update library.", [
//                "Chart updates.",
//                "Coast pilot.",
//                "Light list.",
//                "Tide tables.",
//                "Tidal current tables."
//            ]),
//            "Rebuild main halyard blocks.",
//            "Sew new red ensign."
//        ]
//        default: []
//        }
//    }
//}


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
                "Reset GPS.",
                "Consider removing forward hatch.",
                "Prep mainsail.",
                "Prep jib.",
                "Adjust flags or bimini.",
                "Secure dinghy and lifelines.",
                "Observe wind and tide and log depart.",
                "Raise mainsail if appropriate.",
                "Cast off mooring."
            ]
        case .daysailPostarrival:
            [
                "Secure to mooring and shut off engine.",
                "Log arrival. Export active track log.",
                "Secure mainsail and jib.",
                "Install forward hatch.",
                "Adjust flags or bimini.",
                "Stow pillows, navigation basket, and GPS.",
                "Secure breakers and portholes.",
                "Confirm bilge pump operation.",
                "Sound fuel tank and complete voyage in log.",
                "Transfer track line to phone.",
                "Prepare and load dinghy.",
                "Pack: sunglasses, muck boots.",
                "Update inventory: snacks, drinks.",
                "Confirm hatch is secure.",
                "Confirm mooring is secure.",
                "Write up notes for the day. Match track to trip.",
                "Optionally add photos, upload, and share the trip."
            ]
            
        // MARK: Cruise
        case .cruisePredeparture:
            [
                "Start in app with passengers and possible dates.",
                "Ensure ice blocks and yeti are freezing.",
                "Charge up watch battery pack.",
                "Recharge dehumidifiers.",
                "Confirm inventory: snacks, drinks, outerwear, trash bags, cleaning supplies, linens, gerber multi-tool, safety equipment, propane, fuel, toilet paper, paper towels.",
                "Develop menu for number of meals.",
                "Purchase groceries (and diesel).",
                "Prep food.",
                "Review projects and pack for them.",
                "Pack food.",
                "Pack: clothing, toiletries, devices and chargers (watch battery pack), chainsaw, muck boots, sunglasses, reading materials, instruments.",
                "Fill water. Also top off backup supply and gallon jugs. Update soundings.",
                "Top off fuel.  Update soundings.",
                "Load white dinghy in davits.",
                "Load up early stuff.",
                "Load up refrigeration and dehumidifiers.",
                "Weather and tide confirmed.",
                "Log pre-departure with marine forecast and passenger list.",
                "Secure house for voyage: windows, heat, mail, cat food.",
                "Load up last minute stuff.",
                "Check engine.",
                "Turn on breakers.",
                "Log ice box temp.  Confirm freshwater.",
                "Pass up pillows, navigation basket, and GPS.",
                "Boot up GPS.",
                "Start engine.",
                "Reset GPS.",
                "Consider removing forward hatch.",
                "Prep mainsail.",
                "Prep jib.",
                "Adjust flags or bimini.",
                "Secure dinghy and lifelines.",
                "Observe wind and tide and log depart.",
                "Raise mainsail if appropriate.",
                "Cast off mooring."
            ]
        case .anchoragePrearrival:
            [
                "Observe wind and current. Review overnight forecast.",
                "Setup anchor.",
                "Ballantine main halyard.",
                "Secure jib.",
                "Start engine."
            ]
        case .anchoragePostarrival:
            [
                "Strike mainsail.",
                "Log arrival.",
                "Confirm set and shut off engine.",
                "Secure mainsail.",
                "Sound fuel tank and complete voyage in log. Consider transferring track.",
                "Launch white dinghy for shore excursion.",
                "Secure hatch screens.",
                "Prepare dinner.",
                "Stow pillows, navigation basket, and GPS.",
                "Wash dishes.",
                "Update soundings for water and ice box.",
                "Set out rugs. Light lanterns.",
                "Dump dishwater.",
                "Raise dinghy for sleeping.",
                "Strike flag for sleeping.",
                "Set out forward hatch if it might rain.",
                "Secure hatches and portholes for overnight low.",
                "Illuminate anchor light.",
                "Write up notes for the day.",
                "Secure water breaker if necessary."
            ]
        case .anchoragePredeparture:
            [
                "Secure anchor light.",
                "Raise flag.",
                "Prepare coffee and breakfast.",
                "Wash dishes.",
                "Update soundings for water and ice box.",
                "Review weather and update destination for tonight.",
                "Log pre-departure with marine forecast.",
                "Dump dishwater.",
                "Dry cockpit cushions.",
                "Pass up swill bucket.",
                "Check engine.",
                "Pass up pillows, navigation basket, and GPS.",
                "Boot up GPS.",
                "Secure down below for getting underway. Pick up rugs.",
                "Prep jib.",
                "Hoist dinghy if needed.",
                "Reset GPS.",
                "Prep mainsail.",
                "Consider removing forward hatch.",
                "Anchor up short.",
                "Start engine.",
                "Observe wind and tide and log depart.",
                "Raise mainsail if appropriate.",
                "Raise anchor."
            ]
        case .anchoragePostdeparture:
            [
                "Secure anchor.",
                "Set jib.",
                "Secure engine.",
                "Dump swill bucket."
            ]
        case .cruisePostarrival:
            [
                "Ensure swill is dumped before arriving.",
                "Secure to mooring and shut off engine.",
                "Log arrival. Export active track log.",
                "Secure mainsail and jib.",
                "Sound fuel tank and complete voyage in log.",
                "Transfer track lines to phone.",
                "Stow pillows, navigation basket, and GPS.",
                "Clean swill bucket.",
                "Dump dishwater.",
                "Strip linens.",
                "Sound water, ice box, and propane.",
                "Pack: clothing, toiletries, devices and chargers, sunglasses, muck boots, reading materials, instruments.",
                "Update inventory: snacks, drinks, cleaning supplies, toilet paper, paper towel.",
                "Install forward hatch.",
                "Adjust flags or bimini.",
                "Secure breakers and portholes.",
                "Confirm bilge pump operation.",
                "Prepare and load dinghy.",
                "Confirm hatch is secure.",
                "Confirm mooring is secure.",
                "Write up notes for the day. Match tracks to trips.",
                "Optionally add photos, upload, and share the cruise.",
                "Purchase diesel and snacks.",
                "Go back for ice, trash, linens, dehumidifiers, empty water jugs, white dinghy, chainsaw.",
                "Top off water, snacks, and fuel. Update soundings."
            ]
            
        default: []
        }
    }
}

import SwiftUI
import WxSalt
#Preview {
    NavigationStack {
        AnyChecklistView(checklist: .cruisePostarrival)
            .navigationTitle(ListingPath.cruisePostArrival.label)
            .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
