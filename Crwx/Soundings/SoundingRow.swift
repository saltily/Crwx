//
//  SoundingRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI

struct SoundingRow: View {
    let type: Sounding.T
    var body: some View {
        NavigationLink(destination: SoundingsList(type: type).seaBackground()) {
            Label(type.title, systemImage: type.systemImage)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            Section {
                ForEach(Sounding.T.allCases, id: \.rawValue) { type in
                    SoundingRow(type: type)
                }
            }
            .seaSection()
        }
        .seaBackground()
    }
}
