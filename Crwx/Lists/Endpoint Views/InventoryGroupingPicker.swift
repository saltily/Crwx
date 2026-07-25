//
//  InventoryGroupingPicker.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/25/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct InventoryGroupingPickerMenu: View {
    @Binding var value: InventoryListItem.Grouping
    var body: some View {
        Menu(systemImage: value.systemImage) {
            InventoryGroupingPicker(value: $value)
        }
    }
}
struct InventoryGroupingPicker: View {
    @Binding var value: InventoryListItem.Grouping
    var body: some View {
        Picker("Grouping", selection: $value) {
            ForEach(InventoryListItem.Grouping.allCases, id: \.rawValue) { v in
                Label(v.label, systemImage: v.systemImage).tag(v)
            }
        }
    }
}

#Preview {
    @Previewable @State var value: InventoryListItem.Grouping = .locker
    NavigationStack {
        List {
            InventoryGroupingPicker(value: $value)
                .seaSection()
        }
        .seaBackground()
        .navigationTitle("Something Cool")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                InventoryGroupingPickerMenu(value: $value)
            }
        }
    }
    .environment(\.wxColourScheme, .green)
}
