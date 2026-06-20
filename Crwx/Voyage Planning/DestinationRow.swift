//
//  DestinationRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import SwiftUI
import SwiftData
import FoundationUI
import os

struct DestinationRow: View {
    let harbour: HarbourViewModel
    var body: some View {
        HStack {
            Text(harbour.name)
            Spacer()
            if harbour.route == nil {
                WarningBadge()
            }
            // because badge only appears in list row
            HStack(spacing: 0) {
                Text(harbour.isGenerated ? "*" : "")
                    .opacity(0.5)
                let s = harbour.distanceFromStart.formatted(.number.precision(.fractionLength(0...1)))
                Text("\(s) nm")
            }
            .foregroundStyle(.secondary)
        }
    }
}
struct SwipeDestinationRoutesModifier: ViewModifier {
    @Bindable var start: Harbour
    let destination: HarbourViewModel
    let onDismiss: () -> ()
    @State private var showActions = false
    @State private var startingPoint: RouteSnippet?
    @Environment(\.modelContext) private var context
    func body(content: Content) -> some View {
        content.swipeActions(edge: .leading) {
            Button(systemImage: "pencil.and.scribble") {
                showActions = true
            }
            .tint(.blue)
        }
        .confirmationDialog("Route Actions", isPresented: $showActions) {
            if !destination.isGenerated {
                if destination.route?.sourceId != nil {
                    Button("Edit Existing Route") {
                        startingPoint = destination.route
                    }
                }
                Button("Duplicate Route") {
                    var route = destination.route
                    route?.sourceId = nil
                    startingPoint = route
                }
                Button("Delete Route", role: .destructive) {
                    if let route = Route.find(destination.route?.sourceId, in: context) {
                        context.delete(route) // this should break down the relationships on its own
                        try? context.save()
                        onDismiss()
                    }
                }
            } else {
                Button("Edit Generated Route") {
                    startingPoint = destination.route
                }
                Button("Save Generated Route") {
                    let container = context.container
                    let snippet = destination.route?.points ?? []
                    let task = Task.detached {
                        let actor = RouteLoader(modelContainer: container)
                        try await actor.saveRoute(id: nil, points: snippet, isReviewed: true)
                    }
                    Task {
                        do {
                            try await task.value
                            onDismiss()
                        } catch {
                            logger.critical("Couldn't save generated route: \(error)")
                        }
                    }
                }
            }
            Button("Add Direct Route") {
                startingPoint = .init([
                    .init(start), // this needs to be the starting harbour
                    .init(destination)
                ], generated: true)
            }
        }
        .fullScreenCover(item: $startingPoint) {
            onDismiss()
        } content: { snippet in
            NavigationStack {
                RouteEditor(startingPoint: snippet)
                    .cancelButton()
            }
        }
    }
}
extension View {
    func swipeDestinationRoutes(start: Harbour, destination: HarbourViewModel, onDismiss: @escaping () -> ()) -> some View {
        modifier(SwipeDestinationRoutesModifier(start: start, destination: destination, onDismiss: onDismiss))
    }
}
