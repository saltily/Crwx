//
//  CrwxApp.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/19/26.
//

import SwiftUI
import SwiftData
import FoundationUI

@main
struct CrwxApp: App {
    let container: ModelContainer
    init() {
        self.container = appContainer // previewContainer
    }

    var body: some Scene {
        WindowGroup {
            MobileHomeView()
                .modelContainer(container)
                .locationManager()
                .safari()
                .preferredColorScheme(.dark)
                .receiveGpx(container)
        }
    }
}
