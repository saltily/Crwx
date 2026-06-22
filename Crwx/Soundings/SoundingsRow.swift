//
//  SoundingsRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import WxSalt

struct SoundingsRow: View {
    var body: some View {
        NavigationLink(destination: SoundingsHome().seaBackground()) {
            Label("Inventory", systemImage: "inset.filled.bottomhalf.rectangle")
        }
    }
}

#Preview {
    SoundingsRow()
}
