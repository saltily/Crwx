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
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            MobileHomeView()
                .modelContainer(container)
                .locationManager()
                .safari()
                .preferredColorScheme(.dark)
                .receiveGpx(container)
        }
//        .modelContainer(sharedModelContainer)
    }
}
