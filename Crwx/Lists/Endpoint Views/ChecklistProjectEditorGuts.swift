//
//  ChecklistProjectEditorGuts.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct ChecklistProjectEditorGuts: View {
    @Binding var items: [PackableItem]
    var body: some View {
        Section("Equipment") {
            NavigationLink(destination: ChecklistPackingEditor(items: $items)) {
                Text(items.map(\.label).joined(separator: ", "))
            }
        }
        .seaSection()
        Section("Steps") {
            Text("These can be a full on checkable list just like with a checklist.")
            Text("You can manually order, see sorted to the bottom as checked.")
            Text("You can add and remove.")
            Text("You can further nest and develop.")
            Text("These don't need to be hidden because they are sub to a project but the project might hide when completed.")
            Text("The edit and add buttons will need to be differently purposed here.")
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
        List {
            ChecklistProjectEditorGuts(items: $items)
        }
        .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
