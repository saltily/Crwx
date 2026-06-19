//
//  TowingSymbol.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/8/25.
//

import SwiftUI

struct TowingSymbol: View {
    let dinghy: DinghyOption
    var body: some View {
        switch dinghy {
        case .none:
            Text(" ")
        case .white:
            Image(systemName: "rhombus.fill")
                .foregroundStyle(.white)
        case .green:
            Image(systemName: "rhombus.fill")
                .foregroundStyle(.green)
        }
    }
}

#Preview {
    TowingSymbol(dinghy: .green)
        .seaBackground()
}
