//
//  LogCommandsMenu.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import SwiftUI
import FoundationSalt

struct LogCommandsMenu: View {
    let year: Int
    @State private var trackMatcherIsPresented = false
    var body: some View {
        Menu("Commands", systemImage: "ellipsis.circle") {
            TrackMatcherButton(tracksOnLeft: false, isPresented: $trackMatcherIsPresented)
            SelectMultipleButton()
            Divider()
            BackupButton()
        }
        .trackMatcher(isPresented: $trackMatcherIsPresented, tracksOnLeft: false, year: year)
    }
}

#Preview {
    LogCommandsMenu(year: Date.now.year)
}

