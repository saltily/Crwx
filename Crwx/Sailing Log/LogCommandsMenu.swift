//
//  LogCommandsMenu.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import SwiftUI
import FoundationSalt

struct LogCommandsMenu: View {
    @State private var trackMatcherIsPresented = false
    var body: some View {
        Menu("Commands", systemImage: "ellipsis.circle") {
            YearPicker()
            Divider()
            NavigationLink {
                TrackBrowser()
            } label: {
                Label("Tracks & Routes", systemImage: "map")
            }
            TrackMatcherButton(tracksOnLeft: false, isPresented: $trackMatcherIsPresented)
            SelectMultipleButton()
            Divider()
            BackupButton()
        }
        .trackMatcher(isPresented: $trackMatcherIsPresented, tracksOnLeft: false)
    }
}

#Preview {
    LogCommandsMenu()
}


// MARK: @Year
@propertyWrapper
struct Year: DynamicProperty {
    @AppStorage(.tripsYearKey) private var year: Int = Date.now.year
    var wrappedValue: Int {
        get { year }
        nonmutating set { year = newValue }
    }
    var projectedValue: Binding<Int> {
        .init {
            wrappedValue
        } set: { newValue in
            wrappedValue = newValue
        }

    }
}
extension String {
    static let tripsYearKey = "com.saltily.Mewx.tripsYearKey" // Int
}
