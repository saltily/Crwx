//
//  PackingItemRow.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import FoundationUI

struct PackingItemRow: View {
    @Bindable var item: PackableItem
    @Binding var itemToEdit: PackableItem?
    var body: some View {
        VStack(alignment: .leading) {
            PlaceholderText(item.label, placeholder: "Untitled")
            Text("some other stuff about it")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .onTapGesture {
            itemToEdit = item
        }
    }
}

#Preview {
    @Previewable @State var item: PackableItem = "clear coat"
    PackingItemRow(item: item, itemToEdit: .constant(nil))
}
