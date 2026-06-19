//
//  DoubleText.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/8/25.
//

import SwiftUI

struct DoubleText: View {
    let value: Double?
    var suffix: String?
    var body: some View {
        if let value {
            Text(value, format: .number.precision(.fractionLength(0...1))) + Text(trailing)
        } else {
            (Text("--") + Text(trailing))
                .foregroundStyle(.secondary)
        }
    }
    private var trailing: String {
        if let suffix {
            " \(suffix)"
        } else {
            ""
        }
    }
}

#Preview {
    DoubleText(value: 3.746, suffix: "kts avg")
}
