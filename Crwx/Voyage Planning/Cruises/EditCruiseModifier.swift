//
//  EditCruiseModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/7/25.
//

import SwiftUI

struct EditCruiseModifier: ViewModifier {
    @Bindable var cruise: Cruise
    @State private var model: CruiseViewModel?
    @Environment(\.modelContext) private var context
    func body(content: Content) -> some View {
        Button {
            model = try? cruise.viewModel(in: context)
        } label: {
            content
        }
        .tint(.primary)
        .fullScreenCover(item: $model) { model in
            NavigationStack {
                CruiseForm(model: model)
                    .seaBackground(.darkSeaBlue)
                    .cancelButton()
                    .navigationTitle("Edit Cruise")
                    .navigationBarTitleDisplayMode(.inline)
                    .saveButton {
                        try model.save(in: context)
                    }
            }
        }
        .downloadCharts(cruise)
    }
}
extension View {
    func editCruise(_ model: Cruise) -> some View {
        modifier(EditCruiseModifier(cruise: model))
    }
}
