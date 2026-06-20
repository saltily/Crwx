//
//  RouteEditor+OverlayControls.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/18/25.
//

import SwiftUI
import FoundationSalt
import FoundationUI

extension RouteEditor {
    struct OverlayControls: View {
        @Bindable var route: RouteMaker
        var body: some View {
            HStack {
                if route.state.isIn(.addEnd, .dropOrDeselect) {
                    Button(systemImage: "x.circle") {
                        route.release()
                    }
                }
                Spacer()
                if route.canDeleteFromRoute {
                    Button("", systemImage: "trash", role: .destructive) {
                        route.deleteFromRoute()
                    }
                }
            }
            .buttonStyle(.bordered)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
