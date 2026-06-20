//
//  HubsLink.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/17/25.
//

import SwiftUI
import FoundationUI

struct HubsLink: View {
    @State private var count: Int = 0
    var body: some View {
        NavigationLink(destination: HubsMap()) {
            Label("Hubs", systemImage: "point.3.connected.trianglepath.dotted")
                .badge(count)
                .fetchCount(filter: .hubs, into: $count)
        }
    }
}

#Preview {
    HubsLink()
}
