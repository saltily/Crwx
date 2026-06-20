//
//  ChooseAnchorageRow.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/28/25.
//

import SwiftUI

struct ChooseAnchorageRow: View {
    @AnchorageIntent private var intent
    var body: some View {
        NavigationLink(destination: AnchorageChooser(intent: $intent).seaBackground()) {
            Label("Choose Anchorage", systemImage: "location.magnifyingglass")
        }
    }
}

#Preview {
    ChooseAnchorageRow()
}
