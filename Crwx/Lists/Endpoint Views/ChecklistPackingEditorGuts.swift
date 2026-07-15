//
//  ChecklistPackingEditorGuts.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import WxSalt

struct ChecklistPackingEditor: View {
    @Binding var items: [PackableItem]
    var body: some View {
        List {
            ChecklistPackingEditorGuts(items: $items)
        }
        .seaBackground()
        .packingItemToolbar(items: $items)
    }
}

struct ChecklistPackingEditorGuts: View {
    @Binding var items: [PackableItem]
    var body: some View {
        Section("Items") {
            ForEach(items) { item in
                PackingItemRow(item: item)
            }
            .onDelete { indices in
                items.remove(atOffsets: indices)
            }
            .onMove { indices, i in
                items.move(fromOffsets: indices, toOffset: i)
            }
        }
        .seaSection()
        Section {
            Text("Not for checking off, but for definition.")
            Text("Tap for sheet to get more specific and show the specifics underneath.")
            Text("And perhaps organise them by their specifics.")
        }
        .seaSection()
    }
}

#Preview {
    @Previewable @State var items: [PackableItem] = [
        "clear coat",
        "garden sprayer",
        "foam roller",
        "step ladder",
        "nitrile gloves"
    ]
    NavigationStack {
        ChecklistPackingEditor(items: $items)
    }
    .environment(\.wxColourScheme, .green)
}
