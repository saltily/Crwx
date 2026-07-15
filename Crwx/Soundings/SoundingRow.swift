//
//  SoundingRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import WxSalt
import FoundationUI

struct SoundingRow: View {
    let type: Sounding.T
    var body: some View {
        NavigationLink(type.title, systemImage: type.systemImage, value: type)
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
        .navigationDestination(for: Sounding.T.self) { type in
            SoundingsList(type: type)
                .seaBackground()
        }
    }
}
