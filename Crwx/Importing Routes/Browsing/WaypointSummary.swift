//
//  WaypointSummary.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import FoundationUI

struct WaypointSummary: View {
    @Bindable var waypoint: Waypoint
    var body: some View {
        Label {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading) {
                    PlaceholderText(waypoint.name, placeholder: "Unnamed")
                    HStack(spacing: 5) {
                        Text(subtext)
                        if let source = waypoint.importSource {
                            Image(systemName: source.systemImage)
                                .opacity(0.5)
                        }
                    }
                    .font(.caption)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(waypoint.latitude, format: .latitude.minutes(.fractionLength(1)))
                    Text(waypoint.longitude, format: .longitude.degrees(.wide).minutes(.fractionLength(1)))
                }
                .font(.callout)
                .monospaced()
                .foregroundStyle(.secondary)
            }
        } icon: {
            if let symbol = waypoint.symbol {
                Image(systemName: symbol.systemImage)
                    .foregroundStyle(symbol.colour ?? .accentColor)
            } else {
                Text(" ")
            }
        }
        .opacity(waypoint.isStandalone ? 1 : 0.7)
        .swipeSaveAsHarbour(waypoint: waypoint)
    }
    private var subtext: String {
        var strings = [String]()
//        if !waypoint.source.isEmpty { strings.append(waypoint.source) }
        if let created = waypoint.created {
            strings.append(created.formatted(.dateTime.month(.defaultDigits).day().year(.twoDigits)))
        }
        let routeCount = waypoint.routes?.count ?? 0
        if routeCount != 0 {
            strings.append(routeCount.appending("route", "routes"))
        }
        return strings.joined(separator: ", ")
    }
}
