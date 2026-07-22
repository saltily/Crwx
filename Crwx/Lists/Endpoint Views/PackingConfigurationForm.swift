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
            LockerPicker(value: $model.locker)
            CategoryPicker(value: $model.category)
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
