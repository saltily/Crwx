//
//  SoundingsHome.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import FoundationUI

struct SoundingsHome: View {
    var body: some View {
        List {
            Section {
                ForEach(Sounding.T.allCases, id: \.rawValue) { type in
                    SoundingRow(type: type)
                }
            }
            .seaSection()
        }
        .navigationTitle("Soundings")
    }
}

#Preview {
    SoundingsHome()
}
