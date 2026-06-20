//
//  CruisesRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI

struct CruisesRow: View {
    var body: some View {
        NavigationLink(destination: CruisesList().seaBackground()) {
            Label("Cruises", systemImage: "point.3.connected.trianglepath.dotted")
        }
    }
}

#Preview {
    CruisesRow()
}
