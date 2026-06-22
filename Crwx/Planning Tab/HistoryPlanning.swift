//
//  HistoryPlanning.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/22/26.
//

import SwiftUI
import WxSalt

struct HistoryPlanning: View {
    var body: some View {
        Section("History") {
            CruisesRow()
            TrackBrowserRow(Track.self, .tracks)
        }
        .seaSection()
    }
}

#Preview {
    HistoryPlanning()
}
