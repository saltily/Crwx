//
//  HarbourChooserList.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/23/25.
//

import SwiftUI
import SwiftData
import FoundationUI
import FoundationSalt

struct HarbourChooserList: View {
    @Query<Harbour>(sort: .eastToWest) private var harbours: [Harbour]
    @State private var searchTerm: String = ""
    @State private var showAddNew = false
    @State private var lastVisibleRegion: CoastalRegion?
    @Environment(\.facilitiesFilter) private var filter
    @Environment(\.modelContext) private var context
    @State private var shareState = ShareState()
    var body: some View {
        List {
            ForEach(filteredHarbours.grouped(by: \.coastalRegion, sorting: .init(\.easternLongitude, order: .reverse))) { group in
                Section(group.id.rawValue) {
                    ForEach(group.organised()) { harbour in
                        NavigationLink(destination: HarbourDetail(harbour: harbour)) {
                            HarbourAtAGlance(harbour: harbour)
                                .frame(height: 100, alignment: .top)
                                .padding(.top, 3)
                        }
                        .onScrollVisibilityChange { isVisible in
                            if isVisible {
                                lastVisibleRegion = harbour.coastalRegion
                            }
                        }
                        .banded(harbour.tint, trailing: 10)
                        .swipeDeleteWithConfirmation("Delete Harbour", message: "Are you sure you would like to remove this harbour?  This action cannot be undone.") {
                            let container = context.container
                            let id = harbour.persistentModelID
                            Task.detached {
                                let actor = BackModelActor(modelContainer: container)
                                try await actor.remove(harbour: id)
                            }
                        }
                        .swipeToShare {
                            shareState.start()
                            do {
                                let url = try await harbour.share(context)
                                url.absoluteString.copyToPasteboard()
                                shareState.complete()
                            } catch {
                                shareState.error(error)
                            }
                        }
                    }
                }
            }
            .seaSection()
        }
        .navigationTitle("Harbours")
        .seaBackground()
        .searchable(text: $searchTerm)
        .toolbar {
            Button(systemImage: "plus") {
                showAddNew = true
            }
        }
        .fullScreenCover(isPresented: $showAddNew) {
            NavigationStack {
                AddHarbourPointPicker(region: .fitting(points: harbours.coastalRegion(lastVisibleRegion)), isPresented: $showAddNew)
                    .cancelButton()
                    .saveButton("Done")
                    .navigationTitle("Add Harbour")
                    .navigationBarTitleDisplayMode(.inline)
                    .seaBackground()
            }
        }
        .isSharing(shareState)
    }
    private var facilityFiltered: [Harbour] {
        guard !filter.isEmpty else { return harbours }
        return harbours.filter {
            $0.facilities.contains(filter)
//            !$0.facilities.intersection(filter).isEmpty
        }
    }
    private var filteredHarbours: [Harbour] {
        guard !searchTerm.isEmpty
        else { return facilityFiltered }
        return facilityFiltered.filter {
            $0.matches(term: searchTerm)
        }
    }
}

#Preview {
    HarbourChooserList()
}
