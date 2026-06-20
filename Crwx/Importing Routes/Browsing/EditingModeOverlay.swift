//
//  EditingModeOverlay.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/10/25.
//

import SwiftUI
import FoundationUI

struct EditingModeOverlay: View {
    @Binding var mode: TrackMap.EditingMode
    var body: some View {
        HStack {
            Button(systemImage: mode == .handle ? "rectangle.and.hand.point.up.left.fill" : "rectangle.and.hand.point.up.left") {
                mode = .handle
            }
            Button(systemImage: "scissors") {
                mode = .slice
            }
            Button(systemImage: mode == .erase ? "eraser.fill" : "eraser") {
                mode = .erase
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
