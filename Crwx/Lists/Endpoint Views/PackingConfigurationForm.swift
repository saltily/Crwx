//
//  PackingConfigurationForm.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import SwiftUI
import WxSalt

struct PackingConfigurationForm: View {
    @Binding var model: PackableItem.Configuration
    var body: some View {
        Section {
            Toggle("Dockside", isOn: $model.requiresDockside)
            LifecyclePicker(value: $model.lifecycle)
            Picker("Storage Locker", selection: $model.locker) {
                Text("--").tag(nil as StorageLocker?)
                ForEach(StorageLocker.allCases, id: \.rawValue) { locker in
                    Text(locker.description).tag(locker)
                }
            }
            .pickerStyle(.navigationLink)
            Text("Category").badge("navigation pick or custom")
        } header: {
            Text("Configuration")
        }
        .seaSection()
    }
}

#Preview {
    @Previewable @State var model: PackableItem.Configuration = .init()
    NavigationStack {
        List {
            PackingConfigurationForm(model: $model)
        }
        .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
