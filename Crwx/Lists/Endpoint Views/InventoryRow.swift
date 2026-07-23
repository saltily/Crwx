//
//  InventoryRow.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/23/26.
//

import SwiftUI
import WxSalt
import FoundationSalt

struct InventoryRow: View {
    @Bindable var item: InventoryListItem
    var body: some View {
        HStack(spacing: 10) {
            CheckToggleButton(isOn: $item.checked)
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text(item.label)
                    Spacer()
                    Stepper("quantity", value: $item.quantity)
                        .labelsHidden()
                }
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        if let specs = item.specs {
                            Text(specs)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 5)
                        }
                        Text(item.nextStepsSentence)
                        if let historySentence = item.historySentence {
                            Text(historySentence)
                        }
                        if let matchingCountSentence = item.matchingCountSentence {
                            Text(matchingCountSentence)
                        }
//                        if let combinedSentence = [
//                            item.historySentence,
//                            item.matchingCountSentence
//                        ].compactMap({ $0 }).nilIfEmpty {
//                            Text(combinedSentence.joined(separator: "  "))
//                        }
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    Spacer()
                    TextField("1.0", value: $item.quantity, format: .number)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 50)
                        .font(.title2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
            .onTapGesture {
                item.quantity = 1
//                    itemToEdit = item.contents
            }
        }
        .onChange(of: item.quantity) { oldValue, newValue in
            if newValue != oldValue {
                item.checked = true
            }
        }
    }
}

#Preview {
    @Previewable @State var item: InventoryListItem = .init()
    List {
        InventoryRow(item: item)
            .seaSection()
    }
    .seaBackground()
    .environment(\.wxColourScheme, .green)
}
