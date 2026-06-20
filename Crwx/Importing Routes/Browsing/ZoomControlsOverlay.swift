//
//  ZoomControlsOverlay.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/10/25.
//

import SwiftUI
import MapKit
import FoundationUI

struct ZoomControlsOverlay: View {
    @Binding var region: MKCoordinateRegion
    let showAll: MKCoordinateRegion
    var goMicro: Bool = false
    var body: some View {
        MapControls(.bottomTrailing) {
            HStack {
                if goMicro {
                    Button(systemImage: "sparkle.magnifyingglass") {
                        let deltaRatio = region.span.latitudeDelta / region.span.longitudeDelta
                        var span = region.span
                        span.longitudeDelta = 0.003
                        span.latitudeDelta = deltaRatio * 0.003
                        region.span = span
                    }
                }
                Button(systemImage: "minus.magnifyingglass") {
                    region.zoom(0.91) // inverse of 1.1
                }
                Button(systemImage: "plus.magnifyingglass") {
                    region.zoom(1.1)
                }
                Button(systemImage: "arrow.up.left.and.down.right.magnifyingglass") {
                    region = showAll
                }
            }
            .padding(10)
        }
    }
}
