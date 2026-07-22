//
//  LoadingAndInventoryHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct LoadingAndInventoryHome: View {
    @Environment(PackingStore.self) private var store // only for temporary
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
//        #warning("This is temporary")
        .toolbar {
            ToolbarItem {
                Menu(systemImage: "testtube.2") {
                    Button("Start Daysail") {
                        store.beginDaysail()
                    }
                    Button("End Daysail") {
                        store.endDaysail()
                    }
                    Button("Start Cruise") {
                        store.beginCruise()
                    }
                    Button("End Cruise") {
                        store.endCruise()
                    }
                    Button("Start Season") {
                        store.beginSeason()
                    }
                    Button("End Season") {
                        store.endSeason()
                    }
                }
            }
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
