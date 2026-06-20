//
//  SingleStarRating.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/15/25.
//

import SwiftUI

struct SingleStarRating: View {
    let value: Double
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        Image(systemName: "star.fill")
            .mask {
                OverlayWedge(percent: value)
            }
            .background {
                Image(systemName: "star.fill")
                    .foregroundStyle(colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.2))
            }
    }
    struct OverlayWedge: Shape {
        let percent: Double
        nonisolated func path(in rect: CGRect) -> Path {
            let diameter = min(rect.width, rect.height)
            let radius = 0.5 * diameter
            let centre = CGPoint(x: rect.midX, y: rect.midY)
            return Path { path in
                path.move(to: centre)
                path.addArc(center: centre,
                            radius: radius,
                            startAngle: .degrees(-126),
                            endAngle: .degrees(percent * 360 - 126),
                            clockwise: false
                )
                path.closeSubpath()
            }
        }
    }
}

#Preview {
    SingleStarRating(value: 0.4)
        .foregroundStyle(.yellow)
}
