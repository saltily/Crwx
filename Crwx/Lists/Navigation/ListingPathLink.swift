//
//  ListingPathLink.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import FoundationUI

struct ListingPathLink: View {
    init(_ value: ListingPath) {
        self.value = value
    }
    let value: ListingPath
    var body: some View {
        NavigationLink(value.label, systemImage: value.systemImage, value: value)
    }
}

#Preview {
    ListingPathLink(.projectsAndReminders)
}
