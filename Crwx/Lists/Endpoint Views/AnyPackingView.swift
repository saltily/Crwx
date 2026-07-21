//
//  AnyPackingView.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt
import FoundationUI
import FoundationSalt

struct AnyPackingView: View {
    let filter: PackingFilter?
    @Environment(PackingStore.self) private var store
    var body: some View {
        if let filter {
            NestOne(filter: filter, store: store)
        }
    }
}
fileprivate struct NestOne: View {
    init(filter: PackingFilter, store: PackingStore) {
        let model = store.viewModel(for: filter)
        self.model = model
        self._mutable = .init(initialValue: model)
    }
    let model: PackingListViewModel
    @State private var mutable: PackingListViewModel
    var body: some View {
        NestTwo(model: $mutable)
            .onChange(of: model.filter) { oldValue, newValue in
                mutable = model
            }
    }
}
// MARK: This is the actual view
fileprivate struct NestTwo: View {
    @Binding var model: PackingListViewModel
    @Environment(PackingStore.self) private var store
    var body: some View {
        let items = model.items.sorted()
        List {
            Section {
                ForEach(items) { item in
                    PackingListRow(item: item)
                }
                .onDelete { indices in
                    let ids = items[indices].map(\.id).set
                    model.items.removeAll(where: {
                        ids.contains($0.id)
                    })
                    store.remove(ids: ids)
                }
            }
            .seaSection()
            Section {
                Text("These are all packing lists that I would like to have be easy to interact with.  The differnce is that each is a filter for a certain subset of packable items.  Would be convenient to be able to reorder these.  And when adding, should apply some defaults based on the current filter.")
                Text("Then be able to tap on them to see finer grained details and edit those.  These edits might move them to another screen.")
                Text("Checking them off, should move them down like with projects and reminders tasks.  I'd like them to stay on the screen for a little bit, but then they can cycle away as no longer part of this.  Also might be some action needed to apply to indicate their next destiny.  Maybe I manually indicate when I'm ready to hide the packed items.")
                Text("Might be helpful to be able to organise, search, filter to simplify a larger list.  Like if packing for a cruise, might be a bunch of stuff packed into a cooler and would be nicer to perhaps have a collapsed nest or group of those items.")
                Text("Also this filter should be able to efficiently produce a count of matching unpacked items in the filter, so can show that count on the row linking to this view.  And also show that count somewhere on this view, perhaps as a navigation subtitle.")
            }
            .seaSection()
        }
        .toolbar {
            ToolbarItem {
                Button(systemImage: "plus") {
                    let new = model.filter.new()
                    withAnimation {
                        model.items.append(.init(contents: new, filter: model.filter))
                    }
                    store.add(items: [new])
                }
            }
        }
        .navigationSubtitle(model.subtitleSentence)
    }
}

#Preview {
    @Previewable @State var store: PackingStore = .sample
    NavigationStack {
        AnyPackingView(filter: .takeOut)
            .navigationTitle("Take Out")
            .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
    .environment(store)
}
