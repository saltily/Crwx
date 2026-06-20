//
//  WarningBadge.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import SwiftUI

struct WarningBadge: View {
    var body: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .font(.callout)
            .fontWeight(.heavy)
            .foregroundStyle(.orange)
    }
}

#Preview {
    WarningBadge()
}
