//
//  LoadingAndInventoryHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt

struct LoadingAndInventoryHome: View {
    var body: some View {
        List {
            
            Section("Packing") {
                ListingPathCountingLink(.takeOut, count: 1)
                ListingPathCountingLink(.bringIn, count: 1)
                ListingPathCountingLink(.dockside, count: 1)
                ListingPathCountingLink(.purchase, count: 1)
                ListingPathCountingLink(.prepAshore, count: 1)
            }
            .seaSection()

            Section("Soundings") {
                ForEach(Sounding.T.allCases, id: \.rawValue) { type in
                    SoundingRow(type: type)
                }
            }
            .seaSection()
            
            Section("Inventory") {
                ListingPathLink(.safetyEquipment)
                ListingPathLink(.generalInventory)
            }
            .seaSection()

        }
    }
}

#Preview {
    NavigationStack {
        LoadingAndInventoryHome()
            .navigationTitle("Loading & Inventory")
            .seaBackground()
            .navigationDestination(for: ListingPath.self) { path in
                ListingPathDestinationView(path: path)
                    .navigationTitle(path.label)
                    .seaBackground()
            }
    }
    .environment(\.wxColourScheme, .green)
}
