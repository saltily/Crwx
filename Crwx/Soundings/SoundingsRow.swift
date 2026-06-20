//
//  SoundingsRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI

struct SoundingsRow: View {
    var body: some View {
        NavigationLink(destination: SoundingsHome().seaBackground()) {
            Label("Soundings", systemImage: "inset.filled.bottomhalf.rectangle")
        }
    }
}

#Preview {
    SoundingsRow()
}
