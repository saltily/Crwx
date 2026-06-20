//
//  DeleteSoundingModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import FoundationUI
import SwiftData

struct DeleteSoundingModifier: ViewModifier {
    let model: Sounding
    @Environment(\.modelContext) private var context
    func body(content: Content) -> some View {
        content.swipeDeleteWithConfirmation {
            context.delete(model)
            try context.save()
        }
    }
}

extension View {
    func deleteSounding(_ sounding: Sounding) -> some View {
        modifier(DeleteSoundingModifier(model: sounding))
    }
}
