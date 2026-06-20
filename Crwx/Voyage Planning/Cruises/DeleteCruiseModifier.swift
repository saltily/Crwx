//
//  DeleteCruiseModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/7/25.
//

import SwiftUI
import FoundationUI
import SwiftData

struct DeleteCruiseModifier: ViewModifier {
    let model: Cruise
    @Environment(\.modelContext) private var context
    func body(content: Content) -> some View {
        content
            .swipeDeleteWithConfirmation {
                context.delete(model)
                try context.save()
            }
    }
}
extension View {
    func deleteCruise(_ model: Cruise) -> some View {
        modifier(DeleteCruiseModifier(model: model))
    }
}
