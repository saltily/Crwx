//
//  ListingPathCountingLink.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI

struct ListingPathCountingLink: View {
    init(_ value: ListingPath, count: Int) {
        self.value = value
        self.count = count
    }
    let value: ListingPath
    let count: Int
    var body: some View {
        NavigationLink(value: value) {
            Label(value.label, systemImage: value.systemImage)
                .badge(count)
        }
    }
}

#Preview {
    ListingPathCountingLink(.takeOut, count: 10)
}
