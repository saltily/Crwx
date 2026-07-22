//
//  LifecyclePicker.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import SwiftUI
import WxSalt
import FoundationSalt

struct LifecyclePicker: View {
    @Binding var value: Set<PackedLifecycle>
    var body: some View {
        NavigationLink {
            List {
                Section {
                    ForEach(PackedLifecycle.allCases, id: \.rawValue) { v in
                        Button {
                            if value.contains(v) {
                                value.remove(v)
                            } else {
                                value.insert(v)
                            }
                        } label: {
                            HStack {
                                Text(v.rawValue)
                                Spacer()
                                if value.contains(v) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.accentColor)
                                }
                            }
                        }
                        .tint(.primary)
                    }
                }
                .seaSection()
            }
            .seaBackground()
            .navigationTitle("Lifecycle")
            .navigationBarTitleDisplayMode(.inline)
        } label: {
            let values = value.map(\.rawValue).sorted()
            Text("Lifecycle").badge(values.joined(separator: ", ").nilIfEmpty ?? "--")
        }
    }
}

#Preview {
    @Previewable @State var value: Set<PackedLifecycle> = []
    NavigationStack {
        List {
            LifecyclePicker(value: $value)
                .seaSection()
        }
        .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
