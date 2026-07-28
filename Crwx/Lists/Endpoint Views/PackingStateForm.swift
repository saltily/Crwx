//
//  PackingStateForm.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import SwiftUI
import WxSalt
import FoundationSalt

struct PackingStateForm: View {
    @Binding var model: PackableItem.State
    @Binding var specs: String
    var body: some View {
        Section {
            HStack {
                Text("Status")
                Spacer()
                Picker("Status", selection: $model.status) {
                    ForEach(PackedStatus.allCases) { status in
                        Text(status.description).tag(status)
                    }
                }
                .labelsHidden()
                .fixedSize()
                Image(systemName: model.status.systemImage)
                    .foregroundStyle(.secondary)
            }
            ActionTimeField(value: $model.due)
            HStack {
                Text("Expires")
                TextField("e.g. 7/31/28", value: $model.expires, format: .dateTime.month(.defaultDigits).day().year(.twoDigits))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numbersAndPunctuation)
            }
            VStack(alignment: .leading) {
                TextField("Specs", text: $specs, axis: .vertical)
                    .lineLimit(3...)
                Text("Notes on units counted by the inventory, experiation, brand, where to buy, etc.")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        } header: {
            Text("State")
        }
        .seaSection()
    }
}

#Preview {
    @Previewable @State var model: PackableItem.State = .init(status: .takeOut, due: .anytime, inventory: .onHandToTakeOut)
    @Previewable @State var specs: String = ""
    List {
        PackingStateForm(model: $model, specs: $specs)
    }
    .seaBackground()
    .environment(\.wxColourScheme, .green)
}
