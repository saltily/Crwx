//
//  HarbourRoutesSublist.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/12/25.
//

import SwiftUI
import FoundationUI

struct HarbourRoutesSublist: View {
    @Binding var selectedRoute: (Route, Int)?
    let routes: [Route]
    let pattern: ColorPattern
    let harbourId: UUID
    var body: some View {
        List {
            Group {
                ForEach(0..<routes.count, id: \.self) { i in
                    let route = routes[i]
                    Button {
                        selectedRoute = (route, i)
                    } label: {
                        RouteRow(route: route, colour: pattern[i], harbourId: harbourId)
                    }
                    .tint(.primary)
                    .listRowInsets(.init())
                    .frame(height: 50)
                }
            }
            .seaSection()
        }
        .listSectionSpacing(.compact)
    }
}

fileprivate struct RouteRow: View {
    @Bindable var route: Route
    let colour: Color
    let harbourId: UUID
    var body: some View {
        HStack {
            Rectangle()
                .fill(colour)
                .frame(width: 10)
            Text(label)
                .badge("\(route.length.formatted(.number.precision(.fractionLength(0...1)))) nm")
                .padding(.trailing)
        }
    }
    private var label: String {
        if let end = route.end,
           end.id != harbourId
        { return "to \(end.name)" }
        else if let start = route.start,
                start.id != harbourId
        { return "from \(start.name)" }
        return route.name
    }
}
