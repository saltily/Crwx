//
//  WindLine.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/12/24.
//

import SwiftUI
import WxSalt

struct WindLine: View {
    init(_ label: String = "Wind", wind: WindSnippet) {
        self.label = label
        self.wind = wind
    }
    private let label: String
    private let wind: WindSnippet
    var body: some View {
        LabeledContent(label) {
            HStack {
                WindDirectionSymbol(directions: .init(wind.angle))
                Text(wind.summaryWithGusts)
            }
        }
    }
}

#Preview {
    Form {
        WindLine(wind: .random)
    }
    .preferredColorScheme(.dark)
}
