//
//  NavigationCommandsMenu.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/23/26.
//

import SwiftUI

struct NavigationCommandsMenu: View {
    @State private var isPresented = false
    var body: some View {
        Menu("Commands", systemImage: "ellipsis.circle") {
            ChooseAnchorageButton(isPresented: $isPresented)
        }
        .anchorageChooser(isPresented: $isPresented)
    }
}

#Preview {
    NavigationCommandsMenu()
}
