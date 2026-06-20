//
//  MapMarker+Waypoint.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/18/25.
//

import SwiftUI
import FoundationUI
import FoundationSalt

/// The optional tint or default tint with waypoints is to either force all the same colour and ignore symbol colour or to preserve symbol colour then force a default tint when we don't have a symbol colour
extension MapMarker {
    init(_ point: any Mappable, symbol: WaypointSymbol, tint: Color? = nil) {
        let colour = tint ?? symbol.colour ?? .red
        self.init(point.label ?? "", systemImage: symbol.systemImage, coordinate: point.coordinate, tint: colour)
    }
    init(_ waypoint: WaypointSnippet, tint: Color? = nil, defaultTint: Color? = nil) {
        let color = tint ?? waypoint.tint ?? defaultTint ?? (waypoint.isHub ? .green : (waypoint.isHarbour ? .black : .red))
        let symbol = waypoint.symbol ?? (waypoint.isHub ? .hub : (waypoint.isHarbour ? .anchor : .waypoint))
        self.init(waypoint, symbol: symbol, tint: color)
    }
    init(_ waypoint: Waypoint, tint: Color? = nil, defaultTint: Color? = nil) {
        let color = tint ?? waypoint.tint ?? defaultTint ?? (waypoint.isHub ? .green : (waypoint.isHarbour ? .black : .red))
        let symbol = waypoint.symbol ?? (waypoint.isHub ? .hub : (waypoint.isHarbour ? .anchor : .waypoint))
        self.init(waypoint, symbol: symbol, tint: color)
    }
    init(_ harbour: Harbour, tint: Color? = nil, defaultTint: Color? = nil) {
        let color = tint ?? harbour.tint ?? defaultTint ?? .black
        let symbol = harbour.waypoint?.symbol ?? .anchor
        self.init(harbour, symbol: symbol, tint: color)
    }
}
extension MapBasket {
    func marker(_ point: any Mappable, symbol: WaypointSymbol, tint: Color? = nil) {
        let colour = tint ?? symbol.colour ?? .red
        self.marker(point: point, systemImage: symbol.systemImage, tint: colour)
    }
    func marker(_ waypoint: WaypointSnippet, tint: Color? = nil, defaultTint: Color? = nil) {
        let color = tint ?? waypoint.tint ?? defaultTint ?? (waypoint.isHub ? .green : (waypoint.isHarbour ? .black : .red))
        let symbol = waypoint.symbol ?? (waypoint.isHub ? .hub : (waypoint.isHarbour ? .anchor : .waypoint))
        self.marker(waypoint, symbol: symbol, tint: color)
    }
    func marker(_ waypoint: Waypoint, tint: Color? = nil, defaultTint: Color? = nil) {
        let color = tint ?? waypoint.tint ?? defaultTint ?? (waypoint.isHub ? .green : (waypoint.isHarbour ? .black : .red))
        let symbol = waypoint.symbol ?? (waypoint.isHub ? .hub : (waypoint.isHarbour ? .anchor : .waypoint))
        self.marker(waypoint, symbol: symbol, tint: color)
    }
    func marker(_ harbour: Harbour, tint: Color? = nil, defaultTint: Color? = nil) {
        let color = tint ?? harbour.tint ?? defaultTint ?? .black
        let symbol = harbour.waypoint?.symbol ?? .anchor
        self.marker(harbour, symbol: symbol, tint: color)
    }
    func marker(_ harbour: HarbourViewModel, tint: Color? = nil, defaultTint: Color? = nil) {
        let color = tint ?? harbour.tint ?? defaultTint ?? .black
        self.marker(harbour, symbol: .anchor, tint: color)
    }
    func dot(_ point: (any MapColourable), defaultTint: Color?, width: CGFloat = 10, border: CGFloat = 2) {
        let color = point.tint ?? defaultTint ?? .red
        self.dot(point, tint: color, width: width, border: border)
    }
}
extension NavigationMapLink where Icon == DefaultIcon {
    init(_ point: any Mappable, symbol: WaypointSymbol, tint: Color?, destination: Destination) {
        let colour = tint ?? symbol.colour ?? .red
        self.init(point.label ?? "", systemImage: symbol.systemImage, coordinate: point.coordinate, tint: colour, destination: destination)
    }
    init(_ waypoint: WaypointSnippet, tint: Color? = nil, defaultTint: Color? = nil, destination: Destination) {
        let color = tint ?? waypoint.tint ?? defaultTint ?? (waypoint.isHub ? .green : (waypoint.isHarbour ? .black : .red))
        let symbol = waypoint.symbol ?? (waypoint.isHub ? .hub : (waypoint.isHarbour ? .anchor : .waypoint))
        self.init(waypoint, symbol: symbol, tint: color, destination: destination)
    }
    init(_ waypoint: Waypoint, tint: Color? = nil, defaultTint: Color? = nil, destination: Destination) {
        let color = tint ?? waypoint.tint ?? defaultTint ?? (waypoint.isHub ? .green : (waypoint.isHarbour ? .black : .red))
        let symbol = waypoint.symbol ?? (waypoint.isHub ? .hub : (waypoint.isHarbour ? .anchor : .waypoint))
        self.init(waypoint, symbol: symbol, tint: color, destination: destination)
    }
    init(_ harbour: Harbour, tint: Color? = nil, defaultTint: Color? = nil, destination: Destination) {
        let color = tint ?? harbour.tint ?? defaultTint ?? .black
        let symbol = harbour.waypoint?.symbol ?? .anchor
        self.init(harbour, symbol: symbol, tint: color, destination: destination)
    }
}
protocol MapColourable: Mappable {
    var tint: Color? { get }
}
extension Waypoint: MapColourable {}
extension Harbour: MapColourable {}
extension WaypointSnippet: MapColourable {}
extension HarbourViewModel: MapColourable {}
extension MapDot {
    init(_ point: (any MapColourable), defaultTint: Color?, width: CGFloat = 10, border: CGFloat = 2) {
        let color = point.tint ?? defaultTint ?? .red
        self.init(point, tint: color, width: width, border: border)
    }
}
