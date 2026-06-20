//
//  ReceiveGpxModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/18/25.
//

import SwiftUI
import SwiftData

struct ReceiveGpxModifier: ViewModifier {
    init(container: ModelContainer) {
        engine = .init(container: container)
    }
    @Bindable var engine: ImportEngine
    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                guard url.scheme == "mewx",
                      url == .receiveGpx
                else { return }
                engine.start()
            }
            .watchProgress(engine) { engine in
                ImportProgressView(engine: engine)
                    .presentationDetents([.height(120)])
            }
    }
}

extension View {
    func receiveGpx(_ container: ModelContainer) -> some View {
        modifier(ReceiveGpxModifier(container: container))
    }
}
