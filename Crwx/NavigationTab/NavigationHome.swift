//
//  NavigationHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/23/26.
//

import SwiftUI
import WxSalt

struct NavigationHome: View {
    var body: some View {
        GridHelper()
            .scrollClipDisabled()
            .seaBackground()
            .navigationTitle("Navigator")
            .toolbar {
                ToolbarItem {
                    NavigationCommandsMenu()
                }
            }
    }
}

#Preview {
    NavigationHome()
}
