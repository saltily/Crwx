//
//  SoundingForm.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import WxSalt

struct SoundingForm: View {
    @Bindable var model: SoundingViewModel
    let type: Sounding.T
    let isNew: Bool
    var body: some View {
        List {
            Section {
                DatePicker("Date", selection: $model.date, displayedComponents: [.date, .hourAndMinute])
                switch type {
                case .fuel:
                    FuelEditorRow(model: $model.fuelSounding)
                case .water:
                    Picker("Value", selection: $model.waterValue) {
                        Text("Choose One…").tag(nil as WaterValue?)
                        ForEach(WaterValue.allCases, id: \.rawValue) { wv in
                            Text(wv.description).tag(wv)
                        }
                    }
                case .propane, .iceBox:
                    HStack {
                        Text("Value")
                        TextField("0", value: $model.value, format: .number.precision(.fractionLength(0)))
                            .multilineTextAlignment(.trailing)
                        Text(type.units)
                        Stepper("Value", value: $model.strideableValue)
                            .labelsHidden()
                    }
                }
                TextField("Note", text: $model.note, axis: .vertical)
                    .textInputAutocapitalization(.never)
            } header: {
                HStack {
                    Text(type.name)
                    Spacer()
                    Image(systemName: type.systemImage)
                }
            }
            .seaSection()
        }
        .navigationTitle(isNew ? "Add Sounding" : "Edit Sounding")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SoundingForm(model: .init(), type: .fuel, isNew: true)
}
