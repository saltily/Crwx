//
//  RouteCommands.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import FoundationUI
import SwiftData
import os

struct RouteCommands: ViewModifier {
    @Binding var showProgress: Bool
    @State private var task: Task<Void,Error>?
    @Environment(\.modelContext) private var context
    @State private var routeEditorIsPresented = false
    func body(content: Content) -> some View {
        content.actions {
            AddRouteButton(isPresented: $routeEditorIsPresented)
            Divider()
            WaypointDeduplicationButton()
            Button("Refresh Route Names", systemImage: "arrow.trianglehead.2.clockwise") {
                refreshRouteNames()
            }
        }
        .routeEditor(isPresented: $routeEditorIsPresented)
    }
    private func refreshRouteNames() {
        task?.cancel()
        showProgress = true
        let container = context.container
        let task = Task.detached {
            let actor = BackModelActor(modelContainer: container)
            try await actor.refreshRouteNames()
        }
        self.task = task
        Task {
            do {
                try await task.value
                showProgress = false
            } catch {
                logger.critical("Error refreshing route names: \(error)")
            }
        }
    }
}
extension View {
    func routeCommands(showProgress: Binding<Bool>) -> some View {
        modifier(RouteCommands(showProgress: showProgress))
    }
}
