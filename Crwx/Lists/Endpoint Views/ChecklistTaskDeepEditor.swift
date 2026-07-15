//
//  ChecklistTaskDeepEditor.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import WxSalt

struct ChecklistTaskDeepEditor: View {
    let style: CheckableTask.S
    @Binding var items: [PackableItem]
    @Binding var itemToEdit: PackableItem?
    var body: some View {
        switch style {
        case .packing:
            ChecklistPackingEditorGuts(items: $items, itemToEdit: $itemToEdit)
        case .project:
            ChecklistProjectEditorGuts(items: $items)
        case .plain:
            EmptyView()
        }
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
            ChecklistTaskDeepEditor(style: .project, items: $items, itemToEdit: .constant(nil))
        }
        .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
