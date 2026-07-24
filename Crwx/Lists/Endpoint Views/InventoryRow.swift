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
                    Stepper("quantity") {
                        item.increment()
                    } onDecrement: {
                        item.decrement()
                    }
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
                        Text(item.matchingCountSentence)
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
//                    itemToEdit = item.contents
            }
        }
    }
}

#Preview {
    @Previewable @State var item: InventoryListItem = .init(contents: .init("propane bottles", configuration: .init(specs: "Per bottle. Small camping bottles purchased in 4-pack from Amazon.")), style: .boat)
    List {
        InventoryRow(item: item)
            .seaSection()
    }
    .seaBackground()
    .environment(\.wxColourScheme, .green)
}
