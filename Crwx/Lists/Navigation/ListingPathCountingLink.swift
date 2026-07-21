//
//  ListingPathCountingLink.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI

struct ListingPathCountingLink: View {
    init(_ value: ListingPath) {
        self.value = value
    }
    let value: ListingPath
    @Environment(PackingStore.self) private var store
    var body: some View {
        NavigationLink(value: value) {
            Label(value.label, systemImage: value.systemImage)
                .badge(store.count(for: value.packingFilter))
        }
    }
}

#Preview {
    @Previewable @State var store = PackingStore()
    ListingPathCountingLink(.takeOut)
        .environment(store)
}
