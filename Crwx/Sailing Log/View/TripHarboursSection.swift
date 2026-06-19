//
//  TripHarboursSection.swift
//  Mewx
//
//  Created by Matthew Goacher on 4/4/25.
//

import SwiftUI

struct TripHarboursSection: View {
    let harbours: [Harbour]
    var body: some View {
        if !harbours.isEmpty {
            Section {
                ForEach(harbours) { harbour in
                    HarbourAtAGlance(harbour: harbour)
                }
            }
            .seaSection()
        }
    }
}
