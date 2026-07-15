//
//  ChecklistPackingEditorGuts.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import WxSalt

struct ChecklistPackingEditor: View {
    var body: some View {
        List {
            ChecklistPackingEditorGuts()
        }
        .seaBackground()
    }
}

struct ChecklistPackingEditorGuts: View {
    // likely to take a binding to an ordered set of packable items - or really just definition of such. doesn't need to be classes that can be checked off.
    var body: some View {
        Section("Items") {
            Text("This would be a series of packing items.")
            Text("Not for checking off, but for definition.")
            Text("Add, remove, reorder.")
            Text("Tap for sheet to get more specific and show the specifics underneath.")
            Text("And perhaps organise them by their specifics.")
            Text("I'm gonna want edit button and add button for these.")
        }
        .seaSection()
    }
}

#Preview {
    NavigationStack {
        ChecklistPackingEditor()
    }
    .environment(\.wxColourScheme, .green)
}
