//
//  ProtectionSymbol.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/22/25.
//

import SwiftUI

struct ProtectionSymbol: View {
    let value: ProtectionScore
    var body: some View {
        Middle(value: value.rawValue)
            .frame(width: 30, height: 17)
            .border(.tint)
            .padding(4)
            .background {
                Rectangle()
                    .stroke(.tint, lineWidth: 2)
            }
    }
}
fileprivate struct Middle: View {
    let value: Int
    var body: some View {
        if value == 0 {
            NoGo()
                .stroke(.tint, lineWidth: 3)
        } else {
            Text(value, format: .number)
                .font(.system(size: 15, design: .serif))
                .fontWeight(.bold)
                .foregroundStyle(.tint)
        }
    }
}
fileprivate struct NoGo: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: rect.origin)
            path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
            path.move(to: .init(x: rect.minX, y: rect.maxY))
            path.addLine(to: .init(x: rect.maxX, y: rect.minY))
        }
    }
}
