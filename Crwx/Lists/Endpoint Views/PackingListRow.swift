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
    @Environment(\.halfState) private var halfState
    var body: some View {
        HStack(spacing: 10) {
            if halfState {
                CheckStateButton(value: $item.checkedState)
            } else {
                CheckToggleButton(isOn: $item.checkedState.isChecked)
            }
            PlaceholderText(item.contents.label, placeholder: "Untitled")
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
                .onTapGesture {
                    // edit the item
                }
        }
    }
}

#Preview {
    @Previewable @State var item: PackingListItem = .init(contents: .init("cool stuff", status: .takeOut), filter: .takeOut)
    PackingListRow(item: item)
}
