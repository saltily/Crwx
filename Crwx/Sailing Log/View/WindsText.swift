//
//  WindsText.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/8/25.
//

import SwiftUI

struct WindsText: View {
    let winds: [WindSnippet]?
    var body: some View {
        if let winds {
            Text(winds.summary)
        }
    }
}
