//
//  TrackList.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import SwiftData
import FoundationSalt
import FoundationUI
import WxSalt

struct TrackList: View {
    @Query<Track>(sort: .defaultOrder) private var tracks: [Track]
    @State private var trackMatcherIsPresented = false
    @Environment(\.modelContext) private var context
    @State private var editMode: EditMode = .inactive
    @State private var selection: Set<UUID> = []
    var body: some View {
        List(selection: $selection) {
            Group {
                ForEach(tracks.grouped(by: \.date?.year).sorted(by: \.id, order: .reverse)) { group in
                    let countTrips = group.count
                    let countDays = group.compactMap {
                        $0.date?.dayYear
                    }.set.count
                    Section {
                        ForEach(group) { track in
                            NavigationLink(destination: TrackMap(track: track)) {
                                TrackSummary(track: track)
                            }
                            .swipeDeleteWithConfirmation("Delete Track") {
                                context.delete(track)
                                try? context.save()
                            }
                            .swipeEdit(track: track)
                        }
                    } header: {
                        HStack {
                            Text(group.id?.formatted(.number.grouping(.never)) ?? "")
                            Spacer()
                            Text("\(countTrips.appending("trip", "trips")), \(countDays.appending("day", "days"))")
                        }
                    }
                }
            }
            .seaSection()
        }
        .environment(\.editMode, $editMode)
        .safeAreaInset(edge: .top) {
            if editMode == .active {
                Button("Merge Selection") {
                    mergeSelection()
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
                .disabled(!canMergeSelection())
            }
        }
        .navigationTitle("Tracks")
        .navigationSubtitle(countSentence)
        .toolbar {
            ToolbarItem {
                Menu("Actions", systemImage: "ellipsis.circle") {
                    TrackMatcherButton(tracksOnLeft: true, isPresented: $trackMatcherIsPresented)
                    Button(editMode == .active ? "End Merging Tracks" : "Merge Tracks", systemImage: "arrow.trianglehead.merge") {
                        editMode = editMode == .active ? .inactive : .active
                    }
                }
                .labelsHidden()
            }
        }
        .trackMatcher(isPresented: $trackMatcherIsPresented, tracksOnLeft: true, year: Date.now.year)
        .onDisappear {
            editMode = .inactive
        }
    }
    private var countSentence: String {
        var counts = [String]()
        counts.append(tracks.count.appending("track", "tracks"))
        let days = tracks.compactMap {
            $0.date?.dayYear
        }.set.count
        counts.append(days.appending("day", "days"))
        return counts.joined(separator: ", ")
    }
}

#Preview {
    TrackList()
}


// MARK: Merging
extension TrackList {
    private func canMergeSelection() -> Bool {
        guard selection.count > 1 else { return false }
        let selected = tracks.filter {
            selection.contains($0.id)
        }
        guard selected.count(where: {
            $0.trip != nil
        }) < 2 else { return false }
        return true
    }
    private func mergeSelection() {
        guard canMergeSelection() else { return }
        let selected = tracks.filter {
            selection.contains($0.id)
        }
        guard let keeper = selected.first(where: {
            $0.trip != nil
        }) ?? selected.first else { return }
        let extras = selected.filter {
            $0.id != keeper.id
        }
        guard !extras.isEmpty else { return }
        selection = []
        for extra in extras {
            keeper.segments.append(contentsOf: extra.segments)
            context.delete(extra)
        }
        keeper.remeasure()
        try? context.save()
        editMode = .inactive
    }
}
