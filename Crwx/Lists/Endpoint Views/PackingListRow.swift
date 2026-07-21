//
//  PackingListRow.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import SwiftUI
import FoundationUI

struct PackingListRow: View {
    @Bindable var item: PackingListItem
    @Binding var itemToEdit: PackableItem?
    var body: some View {
        HStack(spacing: 10) {
            CheckStateButton(value: $item.checkedState)
            PackingItemGuts(item: item.contents)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
                .onTapGesture {
                    itemToEdit = item.contents
                }
        }
    }
}

#Preview {
    @Previewable @State var item: PackingListItem = .init(contents: .init("cool stuff", status: .takeOut), filter: .takeOut)
    PackingListRow(item: item, itemToEdit: .constant(nil))
}
