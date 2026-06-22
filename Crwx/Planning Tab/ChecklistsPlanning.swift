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
            Label("Menu", systemImage: "fork.knife")
            Label("Packing List", systemImage: "checklist")
            Label("Safety Equipment", systemImage: "fire.extinguisher")
            Label("Seasonal Checklists", systemImage: "wind.snow")
        }
        .seaSection()
    }
}

#Preview {
    ChecklistsPlanning()
}
