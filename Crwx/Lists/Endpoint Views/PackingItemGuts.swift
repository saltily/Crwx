//
//  PackingItemGuts.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import SwiftUI
import FoundationUI

struct PackingItemGuts: View {
    @Bindable var item: PackableItem
    var body: some View {
        VStack(alignment: .leading) {
            PlaceholderText(item.label, placeholder: "Untitled")
            Text("some other stuff about it")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
}

#Preview {
    PackingItemGuts(item: "hi there")
}
