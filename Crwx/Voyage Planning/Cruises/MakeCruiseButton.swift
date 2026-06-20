//
//  MakeCruiseButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/7/25.
//

import SwiftUI
import FoundationSalt

struct MakeCruiseButton: View {
    let selection: Set<UUID>
    @Environment(\.modelContext) private var context
    @State private var model: CruiseViewModel?
    @State private var isLoading = false
    @Environment(\.editMode) private var editMode
    var body: some View {
        if !selection.isEmpty {
            let trips = selection.compactMap {
                Trip.find($0, in: context)
            }.sorted(by: \.date)
            if !trips.hasCruise,
               trips.isConsecutive
            {
                Button {
                    isLoading = true
                    Task {
                        do {
                            try await makeCruise(trips)
                            isLoading = false
                        } catch {
                            isLoading = false
                            logger.critical("Couldn't make a cruise: \(error)")
                        }
                    }
                } label: {
                    HStack {
                        Label("Make Cruise", systemImage: "arrow.trianglehead.merge")
                        if isLoading {
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .padding(.top)
                .fullScreenCover(item: $model) { model in
                    NavigationStack {
                        CruiseForm(model: model)
                            .seaBackground(.darkSeaBlue)
                            .cancelButton()
                            .navigationTitle("New Cruise")
                            .navigationBarTitleDisplayMode(.inline)
                            .saveButton {
                                try model.save(in: context)
                                editMode?.wrappedValue = .inactive
                            }
                    }
                }
                .font(.body)
            }
        }
    }
    
    private func makeCruise(_ trips: [Trip]) async throws {
        model = try await trips.makeCruise(with: context.container)
        // after it saves, show it banded in the trip list
        // show it locked in the cruise list
    }
}
extension [Trip] {
    var hasCruise: Bool {
        for t in self {
            if t.cruise != nil { return true }
        }
        return false
    }
    var uniqueDays: [Day] {
        self.map { $0.date.day }.set.sorted()
    }
    var isConsecutive: Bool {
        let days = uniqueDays
        guard days.count > 1,
              let first = days.first,
              let last = days.last
        else { return false }
        let daysDuration = (last.end.timeIntervalSince(first.start) / .Day).rounded
        return daysDuration == days.count
    }
}
