//
//  ExposureSymbol.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/20/25.
//

import SwiftUI
import FoundationSalt
import WxSalt

struct ExposureSymbol: View {
    let exposure: CompassExposure
    var body: some View {
        ZStack {
            Image(systemName: "circle")
                .opacity(0.3)
                .overlay(
                    ZStack {
                        ForEach(CompassDirection.cardinal) { direction in
                            if let level = exposure[direction],
                               let angle = direction.direction
                            {
                                WindWedge()
                                    .fill(level.colour)
                                    .rotationEffect(.degrees(180))
                                    .rotationEffect(.degrees(angle.degrees))
                            }
                        }
                    }
                )
        }    }
}

#Preview {
    ExposureSymbol(exposure: .init(protected: .southeast, exposed: .north))
        .preferredColorScheme(.dark)
}
