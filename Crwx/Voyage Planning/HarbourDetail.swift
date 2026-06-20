//
//  HarbourDetail.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/13/25.
//

import SwiftUI
import FoundationUI
import MapKit

struct HarbourDetail: View {
    @Bindable var harbour: Harbour
    @AppStorage(.harbourInfoIsExpandedKey) private var isExpanded = true
    @State private var selectedDestination: HarbourViewModel?
    @State private var showGrid = false
    @AppStorage(.harbourDetailTabKey) private var tab: HarbourTab = .Info
    var body: some View {
        ExpandableSplitView(topCollapsedHeight: 200, bottomCollapsedHeight: 120, isExpanded: $isExpanded) {
            HarbourMap(harbour: harbour, destination: selectedDestination)
                .showTileGrid(showGrid)
        } bottom: {
            ZStack(alignment: .top) {
                HarbourDetailPane(harbour: harbour, isExpanded: isExpanded, tab: tab, selectedDestination: $selectedDestination)
                    .preferredColorScheme(.dark)
                if isExpanded {
                    Picker("Tab", selection: $tab) {
                        Text("Info").tag(HarbourTab.Info)
                        Text("Destinations").tag(HarbourTab.Destinations)
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 5)
                }
            }
            .seaBackground()
        }
        .navigationTitle(harbour.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

