//
//  CruisesList.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import SwiftData
import FoundationUI

struct CruisesList: View {
    @Query(sort: [.init(\Cruise._start, order: .reverse)]) private var cruises: [Cruise]
    @State private var shareState = ShareState()
    @Environment(\.modelContext) private var context
    var body: some View {
        List {
            ForEach(cruises.grouped(by: \._start.year, sorting: .init(\.self, order: .reverse))) { group in
                Section(group.id.formatted(.number.grouping(.never))) {
                    ForEach(group) { cruise in
                        CruiseRow(cruise: cruise)
                            .swipeToShare {
                                shareState.start()
                                do {
                                    let url = try await cruise.share(context)
                                    url.absoluteString.copyToPasteboard()
                                    shareState.complete()
                                } catch {
                                    shareState.error(error)
                                }
                            }
                    }
                }
            }
            .seaSection()
        }
        .navigationTitle("Cruises")
        .toolbar {
            ToolbarItem {
                AddCruiseButton()
            }
        }
        .isSharing(shareState)
    }
}

#Preview {
    CruisesList()
}
