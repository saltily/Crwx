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
                Text("Quantity")
                TextField("0.0", value: $model.quantity, format: .number)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .padding(.trailing, 10)
                Stepper("Quantity", value: $model.quantity)
                    .labelsHidden()
            }
            VStack(alignment: .leading) {
                TextField("Specs", text: $specs, axis: .vertical)
                    .lineLimit(3...)
                Text("Notes on units represented by the quantity, experiation, brand, where to buy, etc.")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        } header: {
            Text("State")
//        } footer: {
//            Text("\(model.stepPhrase(requiresDockside: false).capitalized).")
//                .padding(.bottom)
        }
        .seaSection()
    }
}

#Preview {
    @Previewable @State var model: PackableItem.State = .init(status: .takeOut, due: .anytime)
    @Previewable @State var specs: String = ""
    List {
        PackingStateForm(model: $model, specs: $specs)
    }
    .seaBackground()
    .environment(\.wxColourScheme, .green)
}
