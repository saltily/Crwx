//
//  TrackMatcherButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/7/25.
//

import SwiftUI

struct TrackMatcherButton: View {
    let tracksOnLeft: Bool
    @Binding var isPresented: Bool
    var body: some View {
        Button {
            isPresented = true
        } label: {
            let label = tracksOnLeft ? "Match Trips" : "Match Tracks"
            Label(label, systemImage: "arrow.left.arrow.right")
        }
    }
}

#Preview {
    TrackMatcherButton(tracksOnLeft: true, isPresented: .constant(false))
}
