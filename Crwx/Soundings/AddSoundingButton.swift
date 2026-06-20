//
//  AddSoundingButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import SwiftData
import FoundationUI
import WxSalt

struct AddSoundingButton: View {
    let type: Sounding.T
    @State private var model: SoundingViewModel?
    @Environment(\.modelContext) private var context
    var body: some View {
        Button(systemImage: "plus") {
            let last = try? context.fetch(.lastSounding(of: type)).first
            model = .init(value: last?.value)
        }
        .sheet(item: $model) { model in
            NavigationStack {
                SoundingForm(model: model, type: type, isNew: true)
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
        let new = Sounding(date: model.date, value: model.value, note: model.note, _type: type.rawValue)
        context.insert(new)
        try context.save()
    }
}

#Preview {
    AddSoundingButton(type: .fuel)
}
