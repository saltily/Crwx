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
            Text("Lifecycle").badge("navigate multiple")
            Text("Storage locker").badge("navigate picker")
            Text("Category").badge("navigation pick or custom")
        } header: {
            Text("Configuration")
        }
        .seaSection()
    }
}

#Preview {
    @Previewable @State var model: PackableItem.Configuration = .init()
    List {
        PackingConfigurationForm(model: $model)
    }
    .seaBackground()
    .environment(\.wxColourScheme, .green)
}
