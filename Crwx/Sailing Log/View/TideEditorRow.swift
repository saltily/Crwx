//
//  TideEditorRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/14/24.
//

import SwiftUI

struct TideEditorRow: View {
    @Binding var tide: TidePredictionSnippet
    @Binding var focused: Int?
    let equals: Int
    @FocusState private var hasFocus: Bool
    var body: some View {
        HStack {
            DatePicker("Time", selection: $tide.date, displayedComponents: .hourAndMinute)
            Spacer()
            Picker("Is High", selection: $tide.isHi) {
                Text("H").tag(true)
                Text("L").tag(false)
            }
            TextField("Height", value: $tide.height, format: .number.precision(.fractionLength(0...1)))
                .multilineTextAlignment(.trailing)
                .frame(width: 35)
                .keyboardType(.decimalPad)
                .focused($hasFocus)
                .onSubmit {
                    focused = equals + 1
                }
            Text("ft")
                .foregroundStyle(.secondary)
        }
        .labelsHidden()
        .onChange(of: focused) { oldValue, newValue in
            if newValue == equals {
                hasFocus = true
            }
        }
    }
}

#Preview {
    Form {
        TideEditorRow(tide: .constant([TidePredictionSnippet].random(on: .now)[0]), focused: .constant(nil), equals: 0)
    }
}
