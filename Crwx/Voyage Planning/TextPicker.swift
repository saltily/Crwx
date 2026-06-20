//
//  TextPicker.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/23/25.
//

import SwiftUI
import FoundationUI

struct TextPicker: View {
    init(_ label: String, text: Binding<String>) {
        self.label = label
        self._text = text
    }
    let label: String
    @Binding var text: String
    var body: some View {
        NavigationLink {
            List {
                TextField(label, text: $text, axis: .vertical)
                    .lineLimit(5...)
                    .font(.subheadline)
                    .seaSection()
            }
            .seaBackground(.darkSeaBlue)
            .navigationTitle(label)
            .toolbar {
                Button(systemImage: "document.on.document") {
                    text.copyToPasteboard()
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.headline)
                PlaceholderText(text)
                    .font(.subheadline)
                    .lineLimit(1...3)
            }
        }
    }
}
