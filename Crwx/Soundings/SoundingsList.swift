//
//  SoundingsList.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import SwiftData
import FoundationSalt

struct SoundingsList: View {
    init(type: Sounding.T) {
        self.type = type
        self._soundings = .init(filter: .soundings(of: type), sort: [.init(\.date, order: .reverse)], animation: .default)
    }
    let type: Sounding.T
    @Query private var soundings: [Sounding]
    var body: some View {
        List {
            ForEach(soundings.grouped(by: \.date.year, sorting: .init(\.self, order: .reverse))) { group in
                Section(group.id.formatted(.number.grouping(.never))) {
                    ForEach(group) { sounding in
                        SoundingValueRow(value: sounding)
                    }
                }
            }
            .seaSection()
        }
        .navigationTitle(type.title)
        .toolbar {
            ToolbarItem {
                AddSoundingButton(type: type)
            }
        }
    }
}

#Preview {
    SoundingsList(type: .fuel)
}
