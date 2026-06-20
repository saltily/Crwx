//
//  ProtectionPicker.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/22/25.
//

import SwiftUI

struct ProtectionPicker: View {
    init(_ label: String = "Protection", value: Binding<ProtectionScore?>) {
        self.label = label
        _protection = value
    }
    let label: String
    @Binding var protection: ProtectionScore?
    var body: some View {
        NavigationLink {
            List {
                Group {
                    PickButton(value: $protection, v: nil)
                    ForEach(ProtectionScore.allCases) { score in
                        PickButton(value: $protection, v: score)
                    }
                }
                .seaSection()

            }
            .seaBackground(.darkSeaBlue)
            .navigationTitle("Protection Score")
        } label: {
            HStack {
                Text(label)
                Spacer()
                Group {
                    if let protection {
                        ProtectionSymbol(value: protection)
                    } else {
                        Text("None")
                    }
                }
                .tint(.secondary)
                .foregroundStyle(.secondary)
            }
        }
    }
}

fileprivate struct PickButton: View {
    @Binding var value: ProtectionScore?
    let v: ProtectionScore?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        HStack {
            Label {
                Text(v?.description ?? "None")
            } icon: {
                if let v {
                    ProtectionSymbol(value: v)
                } else {
                    Text(" ")
                }
            }
            Spacer()
            Image(systemName: "checkmark")
                .foregroundStyle(.green)
                .opacity(value == v ? 1 : 0)
        }
        .onTapGesture {
            value = v
            dismiss()
        }
    }
}
