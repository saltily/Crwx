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
                ListingPathCountingLink(.takeOut)
                ListingPathCountingLink(.bringIn)
                ListingPathCountingLink(.dockside)
                ListingPathCountingLink(.purchase)
                ListingPathCountingLink(.prepAshore)
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
    @Previewable @State var store = PackingStore()
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
    .environment(store)
}
