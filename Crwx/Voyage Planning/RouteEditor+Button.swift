//
//  RouteEditor+Button.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/18/25.
//

import SwiftUI
import MapKit

extension RouteEditor {
    struct ActionButton: View {
        @Bindable var route: RouteMaker
        let region: MKCoordinateRegion
        let canAct: Bool
        var body: some View {
            Button(systemImage: route.state.cursorImage) {
                route.act(in: region)
            }
            .font(.largeTitle)
            .padding()
            .contentShape(Circle())
            .fontWeight(canAct ? .regular : .light)
            .tint(canAct ? .green : .gray)
            .offset(
                x: route.state == .dropOrDeselect ? 3 : 0,
                y: route.state == .dropOrDeselect ? 1 : 0
            )
        }
    }
}
