//
//  SailingLookaheadOverlay.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/15/25.
//

import SwiftUI
import FoundationUI
import CoreLocation
import SwiftData
import WxSalt

struct SailingLookaheadOverlay: ViewModifier {
    let centre: CLLocationCoordinate2D
    let model: SailingSnapshotViewModel
    @Binding var path: [LocationSnippet]?
    @State private var isLooking = false
    @Environment(\.modelContext) private var context
    @State private var lookahead: SailingLookaheadViewModel?
    func body(content: Content) -> some View {
        ZStack {
            content
            MapControls(.topLeading) {
                Button(systemImage: "magnifyingglass.circle") {
                    isLooking.toggle()
                }
                .symbolVariant(isLooking ? .fill : .none)
                .padding(10)
            }
            if isLooking {
                Button(systemImage: "scope") {
                    // drop a pin [series of points]
                    lookahead = .init(snapshot: model, location: centre, modelContainer: context.container)
                    path = lookahead?.points
                }
            }
        }
        .sheet(item: $lookahead, onDismiss: {
            path = nil
        }, content: { lookahead in
            SailingLookaheadSheet(model: lookahead)
                .presentationDetents([.height(150)])
                .seaBackground(.darkSeaBlue)
        })
    }
}

extension View {
    func sailingLookaheadOverlay(centre: CLLocationCoordinate2D, model: SailingSnapshotViewModel, path: Binding<[LocationSnippet]?>) -> some View {
        modifier(SailingLookaheadOverlay(centre: centre, model: model, path: path))
    }
}
