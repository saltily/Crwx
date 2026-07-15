//
//  PlanningPath.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import Foundation

enum PlanningPath {
    case harbours, routes, hubs, waypoints
    case cruises, tracks
    case coordinateBrowser
}

extension PlanningPath {
    var label: String {
        switch self {
        case .harbours:
            "Harbours"
        case .routes:
            "Routes"
        case .hubs:
            "Hubs"
        case .waypoints:
            "Waypoints"
        case .cruises:
            "Cruises"
        case .tracks:
            "Tracks"
        case .coordinateBrowser:
            "Coordinate Browser"
        }
    }
    var systemImage: String {
        switch self {
        case .harbours:
            "parkingsign.circle"
        case .routes:
            TrackBrowserType.routes.systemImage
        case .hubs:
            "point.3.connected.trianglepath.dotted"
        case .waypoints:
            TrackBrowserType.waypoints.systemImage
        case .cruises:
            "point.3.connected.trianglepath.dotted"
        case .tracks:
            TrackBrowserType.tracks.systemImage
        case .coordinateBrowser:
            "scope"
        }
    }
}
