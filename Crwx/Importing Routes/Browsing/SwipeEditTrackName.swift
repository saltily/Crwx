//
//  SwipeEditTrackName.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/11/25.
//

import SwiftUI
import FoundationUI
import SwiftData
import WxSalt
import os

struct SwipeEditTrackName: ViewModifier {
    init(track: Track) {
        self.track = track
        _model = .init(initialValue: .init(persistentModel: track))
    }
    @Bindable var track: Track
    @State private var isPresented = false
    @State private var model: TrackNameViewModel
    @Environment(\.modelContext) private var context
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading) {
                Button(systemImage: "pencil.circle") {
                    model = .init(persistentModel: track)
                    isPresented = true
                }
                .tint(.blue)
            }
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    List {
                        Group {
                            TextField("Name", text: $model.name)
                            TextField("Date", value: $model.date, format: .dateTime.month(.defaultDigits).day().year(.twoDigits))
                        }
                        .seaSection()
                    }
                    .seaBackground(.darkSeaGreen)
                    .cancelButton()
                    .saveButton {
                        let container = context.container
                        let task = Task.detached {
                            let actor = BackModelActor(modelContainer: container)
                            try await actor.save(track: model)
                        }
                        Task {
                            do {
                                try await task.value
                            } catch {
                                logger.critical("Couldn't save track changes: \(error)")
                            }
                        }
                        return true
                    }
                }
                .presentationDetents([.medium])
            }
    }
}
extension View {
    func swipeEdit(track: Track) -> some View {
        modifier(SwipeEditTrackName(track: track))
    }
}
