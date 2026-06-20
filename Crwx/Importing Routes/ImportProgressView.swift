//
//  ImportProgressView.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import FoundationUI

struct ImportProgressView: View {
    @Bindable var engine: ImportEngine
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            switch engine.step {
            case .idle:
                EmptyView()
            case .loadingFiles:
                Text("Importing GPS and route data…")
                ProgressMessage(message: "Loading files…")
            case .parsingGpx(let tracker):
                Text("Importing GPS files…")
                ProgressDisplay(tracker: tracker)
            case .parsingNob(let tracker):
                Text("Importing RosePoint files…")
                ProgressDisplay(tracker: tracker)
            case .cleanup:
                Text("Cleaning up…")
                ProgressMessage(message: "Deleting stray files…")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

