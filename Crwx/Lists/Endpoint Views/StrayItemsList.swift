//
//  StrayItemsList.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/24/26.
//

import SwiftUI
import WxSalt

struct StrayItemsList: View {
    var body: some View {
        List {
            Section {
                Text("These items do not appear in inventory lists or any active checklist to be moved or as recently removed.")
                Text("Consider deleting, flagging to include in inventory, and setting due for a shift.")
            }
            .seaSection()
            Section {
                Text("These will be packable items that I'm not checking off or inventorying, but just want to see that they are here and maybe delete them or maybe change them to appear in inventory or another list.")
            }
            .seaSection()
        }
        .navigationSubtitle("4 items")
    }
}

#Preview {
    @Previewable @State var store: PackingStore = .sample
    NavigationStack {
        StrayItemsList()
            .seaBackground()
            .navigationTitle("Hidden Items")
    }
    .environment(\.wxColourScheme, .green)
    .environment(store)
}
