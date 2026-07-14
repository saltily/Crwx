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
                Text("Purchase")
                Text("Prepare Ashore")
                Text("Take Out")
                Text("Bring In")
                Text("Dockside")
            }
            .seaSection()

            Section("Soundings") {
                ForEach(Sounding.T.allCases, id: \.rawValue) { type in
                    SoundingRow(type: type)
                }
            }
            .seaSection()
            
            Section("Inventory") {
                Text("Safety Equipment")
                Text("General Inventory")
            }
            .seaSection()

        }
    }
}

#Preview {
    LoadingAndInventoryHome()
}
