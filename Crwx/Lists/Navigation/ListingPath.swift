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
    case prepAshore
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
    case voyagePlanning
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
        case .prepAshore:
            "Prep Ashore"
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
        case .voyagePlanning:
            "Voyage Plan"
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
        case .generalInventory:
            "inset.filled.bottomhalf.rectangle"
        case .takeOut:
            "arrow.right"
        case .bringIn:
            "arrow.left"
        case .dockside:
            "shippingbox"
        case .purchase:
            "dollarsign"
        case .prepAshore:
            "app.gift"
        case .cruisePostArrival, .daysailPostArrival:
            "book.closed"
        case .anchoragePostArrival:
            "moon.zzz"
        case .anchoragePreDeparture:
            "sun.horizon.fill"
        case .cruisePreDeparture, .daysailPreDeparture:
            "book.pages"
        case .anchoragePreArrival:
            "square.grid.2x2"
        case .anchoragePostDeparture:
            "squareshape.split.2x2"
        case .voyagePlanning:
            "p.circle"
        default: "questionmark"
        }
    }
}
