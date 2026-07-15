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


// MARK: Daysail
extension Checklist {
    var viewModel: ChecklistViewModel {
        switch self {
        case .daysailPredeparture:
            [
                "Weather and tide confirmed.",
                "Log pre-departure with marine forecast and passenger list.",
                .daysailPreConfirm,
                .daysailPack,
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
                .daysailPack,
                .daysailPostConfirm,
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
                .cruisePreConfirm,
                "Develop menu for number of meals.",
                "Purchase groceries (and diesel).",
                "Prep food.",
                "Review projects and pack for them.",
                .cruisePackFood,
                .cruisePackPersonal,
                .cruisePackChainsaw,
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
                .cruisePackPersonal,
                .cruisePostConfirm,
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
                .cruiseCleanup,
                "Top off water, snacks, and fuel. Update soundings."
            ]
            
        // MARK: Spring
        case .springFitOut:
            [
                "Ensure winter maintenance completed.",
                .fitoutPurchase,
                .fitoutTakeOver,
                "Remove shrink wrap.",
                .fitoutBringHome,
                // engine
                .enginePurchase,
                "Charge batteries.",
                "Add fuel. Update sounding.",
                "Oil change.",
                "Change fuel filters.",
                "Install batteries.",
                "Run engine.",
                "Install water heater.",
                "Fill water.",
                "Test plumbing and electrical systems.",
                "Inspect sea cocks.  Test bilge pumps.",
                // bottom
                .hullPurchase,
                "Pressure wash hull.",
                "Fibreglass repairs.",
                "Paint green.",
                "Clean sea cocks.",
                "Weld repair cages.",
                "Paint transducer.",
                "Paint cages.",
                "Paint bottom.",
                "Apply clear coat.",
                "Apply new lettering.",
                // mast
                "Any mast work or repairs.",
                "Replace flag halyards as needed.",
                "Secure spreader braces as needed.",
                // dock
                "Dock repairs to rotten decking.",
                "Put out fixed dock.",
                "Put out floats and ramp.  Remember concrete pads and extra float.",
                "Attach chains.",
                "Put out dock offhaul.",
                // dinghy
                "Charge dinghy batteries.",
                "Tackle dinghy leaks.",
                "Paint dinghies.",
                "Green dinghy online with decking, batteries, bilge pump, solar, oars, and motor.",
            ]
        case .springLaunch:
            [
                "Register sailboat.",
                "Schedule launch for a high tide in May.",
                "Install registration stickers. Stow registration on board.",
                "Confirm: GPS, VHF, flashlight(s), charts, fleece, rain slicker.",
                "Confirm engine runs.",
                "Lash down for road travel.",
                "Setup mooring pendant.",
                "Pack: dinghy, oars, ladder.",
                "Splash and transit.",
                "Retrieve vehicle."
            ]
        case .springUprig:
            [
                "Confirm inventory of cotter pins and rings.",
                "Install main halyard aloft on mast. Ensure will be able to pull it down once mast is up.",
                "Remove mast lashings.  Confirm lifting strap.",
                "Secure furler foot near bow.",
                "Ensure davits are removed and left ashore.",
                "Plan to arrive Bucks Harbour between half tide and hour before/after low. Plan for 1-2 hours transit.",
                "Setup fenders and docklines.  Moor to minimise crunching and surging.  Advise long leads.  Don't goo too far forward.",
                "Raise mast.  Pay close attention to furler, backstay, aloft entanglement with crane and pier.  Also watch docklines for change of tide.",
                "Tighten four points, disconnect from crange, proceed to anchor.",
                "Attach shrouds and furler and tune the rig.",
                "Ensure sufficient wraps with furler downhaul.  Jib green is on starboard side so must furl when pulling counterclockwise, so load the furler by turning clockwise when looking down.",
                "Hoist and furl jib.  Coil halyard.",
                "Install mainsail on boom.",
                "Install mainsail battens.",
                "Seat boom and topping lifts.",
                "Reave mainsheet.",
                "Raise mainsail.",
                "Secure lazyjacks.",
                "Furl mainsail.",
                "Install boom crutch.",
                "Install bimini.",
                "Plug in mast wiring.",
                "Raise flags.",
                "Install lifelines.",
            ]
        case .springLoading:
            [
                "Distribute cushions.",
                "Registration and MITA guide.",
                "Library.  Includes manuals and books: light list, coast pilot, chart number 1, rules of the road, weather guide, 12 volt bible, arts of the sailor.  New excerpts from tide and current tables in the spring.  And possibly latest coast pilot and light list pages to reflect latest notices to mariners.",
                "Matches.",
                "Salt and pepper, peanut butter.  Maybe just store for the winter as I tend to already have these provided for at home.  Same for little tub of sugar.",
                "Aerosols.",
                "Tea, oatmeal, granola bars, nuts, crackers, tinned foods like soups and beans, coffee.  All of this can go back into home circulation.  Then restock with fresh items in the spring.",
                "Spotlight and VHF.  Recharge both in the fall and the spring.  It is best to store batteries fully charged.",
                "Dehumidifiers.  Just stow them somewhere safe and recharge them in the spring.  Make sure they aren't crushed or jostled around or they could spill their guts (don't put them in linen trash bags).",
                "Flashlights, head lamps, fans, iPhone speaker box, spare batteries.  Stow somewhere warm for the winter, then check them in the spring.  Replace batteries as needed in the spring.  Purchase more battery stock as needed.  Perhaps use a battery tester.",
                "GPS units.  Stow them in the office and harvest routes and other data.",
                "Pillows.  Throw pillows and for the v-berth.  Waterproof bags.  Grundens, rain slicker.  Boat shoes.",
                "Fleece, windbreaker, spare socks, spare pants.  Launder and put into winter circulation.",
                "Sleeping bag.  Into winter circulation (I keep it in my truck).",
                "Bedding, blankets, pillowcases, towels.  Launder and store with pillows in shed in trash bag with dryer sheets.",
                "Sails in bags, sail cover, and Dad's foul-weather gear.  These can stay on board in a closet with dryer sheets.  Also surplus paper towel and toilet paper and rags / bilge diapers can stay aboard in save storage."
            ]
            
        // MARK: Fall
        case .fallOffloading:
            [
                "Be sure to leave for end: GPS, VHF, flashlight(s), charts, fleece, rain slicker.",
                "Stow cushions in vee berth with dryer sheets.",
                "Remove davits.",
                "Registration and MITA guide.",
                "Library.  Includes manuals and books: light list, coast pilot, chart number 1, rules of the road, weather guide, 12 volt bible, arts of the sailor.  New excerpts from tide and current tables in the spring.  And possibly latest coast pilot and light list pages to reflect latest notices to mariners.",
                "Matches.",
                "Salt and pepper, peanut butter.  Maybe just store for the winter as I tend to already have these provided for at home.  Same for little tub of sugar.",
                "Aerosols.",
                "Tea, oatmeal, granola bars, nuts, crackers, tinned foods like soups and beans, coffee.  All of this can go back into home circulation.  Then restock with fresh items in the spring.",
                "Spotlight and VHF.  Recharge both in the fall and the spring.  It is best to store batteries fully charged.",
                "Dehumidifiers.  Just stow them somewhere safe and recharge them in the spring.  Make sure they aren't crushed or jostled around or they could spill their guts (don't put them in linen trash bags).",
                "Flashlights, head lamps, fans, iPhone speaker box, spare batteries.  Stow somewhere warm for the winter, then check them in the spring.  Replace batteries as needed in the spring.  Purchase more battery stock as needed.  Perhaps use a battery tester.",
                "GPS units.  Stow them in the office and harvest routes and other data.",
                "Pillows.  Throw pillows and for the v-berth.  Waterproof bags.  Grundens, rain slicker.  Boat shoes.",
                "Fleece, windbreaker, spare socks, spare pants.  Launder and put into winter circulation.",
                "Sleeping bag.  Into winter circulation (I keep it in my truck).",
                "Bedding, blankets, pillowcases, towels.  Launder and store with pillows in shed in trash bag with dryer sheets.",
                "Sails in bags, sail cover, and Dad's foul-weather gear.  These can stay on board in a closet with dryer sheets.  Also surplus paper towel and toilet paper and rags / bilge diapers can stay aboard in save storage.",
                "Charts (optional)."
            ]
        case .fallDownrig:
            [
                "Confirm sufficient fuel for the trip.  It will take about 3 gallons to motor round trip.",
                "Pack or purchase: dryer sheets.",
                "Remove bimini and stow below.",
                "Remove boom crutch and stow on housetop.",
                "Protect bimini with plastic and dryer sheets.",
                "Unplug mast wiring.",
                "Plan to arrive Bucks Harbour between half tide and hour before/after low. Plan for 1-2 hours transit.  Timing is good if leaving just after high tide.",
                "Prep anchor and ballantine jib halyard.",
                "Strike jib onto deck instead of furling.",
                "Anchor for 2 hours to prepare to go dockside.",
                "Stow jib in sailbag with dryer sheets.",
                "Strike and unbend mainsail from mast.",
                "Remove battens from mainsail and stow below.",
                "Remove mainsheet.",
                "Secure topping lifts and lazyjacks to pinrail.",
                "Remove boom and stow mainsail in sailbag with dryer sheets.",
                "Stow flags.",
                "Stow lifelines.",
                "Disconnect furler.  Put pieces in bucket down below.  Secure foot forward.",
                "Prep shrouds with safety lines.",
                "Attach taglines and lifting strap to mast.",
                "Setup fenders and docklines.  Moor to minimise crunching and surging.  Advise long leads.  Don't goo too far forward.",
                "Lower the mast.  Shouldn't take more than 30 minutes.  Carefully monitor furler, backstay, and entanglement aloft on pier or crane.",
                "Secure any loose lines that may be over the side.",
                "Cast off and motor home.",
            ]
        case .fallHaulout:
            [
                "Schedule for a high tide in October.  Late October far more likely to be freezing cold with stormy winds.",
                "Ensure mast is lashed for road travel.",
                "Ensure sufficient fuel for trip to Machias.",
                "Remove main halyard and bring blocks ashore for winter maintenance.",
                "Loosen mooring shackle.",
                "Stage vehicle with ladder.  Inspect at low tide and remove any rocks or obstructions.",
                "Tow white dinghy astern.",
                "Wear rubber boots.",
                "Ideally unscrew pendant and bring on voyage.",
                "Plan for 1 hour transit.",
                "Dump water tank en route.",
                "If hanging off piling upon arrival, ensure furler doesn't tangle on piling."
            ]
        case .fallLayup:
            [
                .layupPurchase,
                "Be sure to leave for end: GPS, VHF, flashlight(s), charts, fleece, rain slicker.",
                "Antifreeze gallon through toilet, through engine, and some into bilge.  Then secure sea cocks.",
                "Offload water heater.",
                "Disconnect propane bottles.",
                "Close fuel valves.",
                "Drain racor.",
                "Close sea cocks except for sink drains and cockpit.",
                // shrink wrap
                .shrinkWrapPurchase,
                "Install belly ropes.  Tie ramp in position with knee pads.",
                "Remove helm and build frame over cockpit.",
                "Cover and shrink with plastic.",
                // dinghies
                "Bring in mooring pendant if necessary.",
                "Stow dinghy batteries in shop.",
                "Stow oar locks in shop.",
                "Stow trolling motor in garden space.",
                // dock
                "Bring in offhaul, install chain marker and buoy. Best to unreeve at high tide so clean.",
                "Install wheels under dock ramp.",
                "Disconnect dock chains.  Bring in bench.",
                "Remove dock ramp and floats.  Remove cement pads.",
                "Remove fixed dock.",
                "Ensure fixed pier is optimised for success.  Take photos and measurements.  Double-up chains and wires.",
                "Remove green dinghy decking and stow upside down on dock.  Be gentle with green flop and solar panels and bilge pump.",
                "Wash bedding, towels, blankets, pillow cases, spare clothing.",
                "Recharge VHF and spotlight.  Also recharge all marine batteries, including dinghy batteries, after topping off water in batteries.",
                "Put clothing in dresser, sleeping bag in truck, most food in kitchen (except for salt and pepper, sugar and peanut butter).",
                "Put GPS units at desk upstairs.",
                "Stow charts under the bed.",
                "Stow other linens and bedding in trash bag with dryer sheets in storage unit.",
                "Stow remaining documents, matches, flashlights, electronics, batteries, foodstuffs in tote in storage unit."
            ]
            
        // MARK: Winter
        case .winterMaintenance:
            [
                .winterPurchase,
                "Rebuild main halyard blocks.",
                "Sew new red ensign.",
                "Make new mooring pendant.",
                "Chart updates.",
                "Coast pilot.",
                "Light list.",
                "Tide tables.",
                "Tidal current tables."
            ]
            
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
