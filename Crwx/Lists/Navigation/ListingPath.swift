//
//  ListingPath.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import Foundation

/// Something to use with navigation links and navigation paths.
enum ListingPath {
    
    // MARK: Loading & Inventory
    case loadingAndInventory
    case dockside
    case purchase
    case takeOut
    case bringIn
    case safetyEquipment
    case generalInventory
    
    // MARK: Projects & Reminders
    case projectsAndReminders
    
    // MARK: Daysail Checklists
    case daysailChecklists
    case daysailPreDeparture
    case daysailPostArrival
    
    // MARK: Cruise Checklists
    case cruiseChecklists
    case menu
    case cruisePreDeparture
    case anchoragePreArrival
    case anchoragePostArrival
    case anchoragePreDeparture
    case anchoragePostDeparture
    case cruisePostArrival
    
    // MARK: Seasonal Checklists
    case seasonalChecklists
    case springFitOut
    case springLaunch
    case springUprig
    case springLoading
    case fallOffloading
    case fallDownrig
    case fallHaulout
    case fallLayup
    
}


// MARK: Titles
extension ListingPath {
    var label: String {
        switch self {
        case .loadingAndInventory:
            "Loading & Inventory"
        case .dockside:
            "Dockside"
        case .purchase:
            "Purchase"
        case .takeOut:
            "Take Out"
        case .bringIn:
            "Bring In"
        case .safetyEquipment:
            "Safety Equipment"
        case .generalInventory:
            "General Inventory"
        case .projectsAndReminders:
            "Projects & Reminders"
        case .daysailChecklists:
            "Daysail Checklists"
        case .daysailPreDeparture:
            "Pre-Departure"
        case .daysailPostArrival:
            "Post-Arrival"
        case .cruiseChecklists:
            "Cruise Checklists"
        case .menu:
            "Menu"
        case .cruisePreDeparture:
            "Pre-Departure"
        case .anchoragePreArrival:
            "Anchor Pre-Arrival"
        case .anchoragePostArrival:
            "Anchor Post-Arrival"
        case .anchoragePreDeparture:
            "Anchor Pre-Departure"
        case .anchoragePostDeparture:
            "Anchor Post-Departure"
        case .cruisePostArrival:
            "Post-Arrival"
        case .seasonalChecklists:
            "Seasonal Checklists"
        case .springFitOut:
            "Fit-Out"
        case .springLaunch:
            "Launch"
        case .springUprig:
            "Uprig"
        case .springLoading:
            "Loading"
        case .fallOffloading:
            "Offloading"
        case .fallDownrig:
            "Downrig"
        case .fallHaulout:
            "Haulout"
        case .fallLayup:
            "Layup"
        }
    }
}


// MARK: Icons
extension ListingPath {
    var systemImage: String {
        switch self {
        case .loadingAndInventory:
            "pencil.and.list.clipboard"
        case .projectsAndReminders:
            "checklist"
        case .daysailChecklists:
            "sailboat"
        case .cruiseChecklists:
            "point.3.connected.trianglepath.dotted"
        case .seasonalChecklists:
            "wind.snow"
        case .menu:
            "fork.knife"
        case .safetyEquipment:
            "fire.extinguisher"
        default: "questionmark"
        }
    }
}
