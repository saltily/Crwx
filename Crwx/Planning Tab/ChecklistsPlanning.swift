//
//  ChecklistsPlanning.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/22/26.
//

import SwiftUI
import WxSalt

struct ChecklistsPlanning: View {
    var body: some View {
        Section("Lists") {
            SoundingsRow()
            Text("Menu")
            Text("Packing List")
            Text("Inventory")
            Text("Safety Equipment")
            Text("Seasonal Checklists")
        }
        .seaSection()
    }
}

#Preview {
    ChecklistsPlanning()
}
