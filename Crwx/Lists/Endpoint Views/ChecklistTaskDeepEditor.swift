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
    var body: some View {
        switch style {
        case .packing:
            ChecklistPackingEditorGuts()
        case .project:
            ChecklistProjectEditorGuts()
        case .plain:
            EmptyView()
        }
    }
}

#Preview {
    NavigationStack {
        List {
            ChecklistTaskDeepEditor(style: .project)
        }
        .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
