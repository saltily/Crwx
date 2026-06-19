//
//  SelectMultipleButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI

struct SelectMultipleButton: View {
    @Environment(\.editMode) private var editMode
    var body: some View {
        Button("Select Multiple", systemImage: image) {
            if editMode?.wrappedValue == .active {
                editMode?.wrappedValue = .inactive
            } else {
                editMode?.wrappedValue = .active
            }
        }
    }
    private var image: String {
        if editMode?.wrappedValue == .active {
            "checkmark.circle.fill"
        } else {
            "checkmark.circle"
        }
    }
}

#Preview {
    SelectMultipleButton()
}
