//
//  WindsStack.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/8/25.
//

import SwiftUI
import WxSalt

struct WindsStack: View {
    let winds: [WindSnippet]?
    var body: some View {
        if let winds {
            VStack(alignment: .leading) {
                ForEach(0..<winds.count, id: \.self) { i in
                    let wind = winds[i]
                    HStack {
                        WindDirectionSymbol(directions: .init(wind.angle))
                        Text(wind.speedSummaryWithGusts)
                    }
                }
            }
        }
    }
}
