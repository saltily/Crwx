//
//  HarboursRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/12/25.
//

import SwiftUI
import SwiftData
import FoundationUI

struct HarboursRow: View {
    @State private var count: Int = 0
    var body: some View {
        NavigationLink(destination: HarbourChooser()) {
            Label("Harbours", systemImage: "parkingsign.circle")
                .badge(count)
                .fetchCount(Harbour.self, into: $count)
        }
    }
}

#Preview {
    HarboursRow()
}
