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
            PlanningPathLink(.cruises)
            PlanningPathCountingLink(.tracks, type: Track.self)
        }
        .seaSection()
    }
}

#Preview {
    HistoryPlanning()
}
