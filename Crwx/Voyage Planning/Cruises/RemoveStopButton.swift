//
//  RemoveStopButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/7/25.
//

import SwiftUI
import FoundationSalt
import os
import FoundationUI

struct RemoveStopButton: View {
    let i: Int
    @Bindable var model: CruiseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var error: Error?
    var body: some View {
        if model.canRemove(at: i) {
            Button("Remove Stop", systemImage: "trash", role: .destructive) {
                Task {
                    do {
                        try await model.remove(at: i)
                        dismiss()
                    } catch {
                        logger.critical("Couldn't remove the stop: \(error)")
                        self.error = error
                    }
                }
            }
            .errorAlert(error: $error)
        }
    }
}
