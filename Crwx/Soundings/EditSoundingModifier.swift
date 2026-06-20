//
//  EditSoundingModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import SwiftData
import WxSalt
import FoundationUI

struct EditSoundingModifier: ViewModifier {
    let sounding: Sounding
    @State private var model: SoundingViewModel?
    @Environment(\.modelContext) private var context
    func body(content: Content) -> some View {
        Button {
            model = .init(date: sounding.date, value: sounding.value, note: sounding.note)
        } label: {
            content
                .tint(.primary)
        }
        .sheet(item: $model) { model in
            NavigationStack {
                SoundingForm(model: model, type: sounding.type, isNew: true)
                    .seaBackground(.darkSeaBlue)
                    .cancelButton()
                    .saveButton {
                        try await save(model: model)
                    }
            }
            .presentationDetents([.medium])
        }
    }
    private func save(model: SoundingViewModel) async throws {
        sounding.date = model.date
        sounding.value = model.value
        sounding.note = model.note
        try context.save()
    }
}
extension View {
    func editSounding(_ sounding: Sounding) -> some View {
        modifier(EditSoundingModifier(sounding: sounding))
    }
}
