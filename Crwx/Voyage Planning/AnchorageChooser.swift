//
//  AnchorageChooser.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/27/25.
//

import SwiftUI
import FoundationUI
import SwiftData

/// This outside wrapper serves to just load an initial intent based on history in the context
struct AnchorageChooser: View {
    @Binding var intent: VoyageIntent
    @Environment(\.modelContext) private var context
    var body: some View {
        Group {
            NestOne(intent: $intent, anchorages: .init(container: context.container))
        }
        .navigationTitle("Next Stop")
    }
}

/// This takes the loaded intent and uses it to power the filtered views and editing that intent to filter the views.  This owns that intent.
fileprivate struct NestOne: View {
    @Binding var intent: VoyageIntent
    @State var anchorages: PotentialAnchorages
    @State private var destinations: HarbourDestinations = .init()
    @State private var tab: Int = 1
    @Environment(\.modelContext) private var context
    @State private var facilitiesFilter: Facilities = .empty
    var body: some View {
        AnchorageBrowser(tab: tab, intent: $intent, destinations: destinations, anchorages: anchorages)
            .environment(\.facilitiesFilter, facilitiesFilter)
        .safeAreaInset(edge: .bottom) {
            HStack {
                AnchorageFacilitiesFilterMenu(facilities: $facilitiesFilter)
                Picker("Tab", selection: $tab) {
                    Image(systemName: "map").tag(1)
                    Image(systemName: "list.bullet").tag(2)
                }
                .symbolVariant(.fill)
                .labelsHidden()
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .background(.thinMaterial)
            .onChange(of: intent.start, initial: true) { oldValue, newValue in
                destinations.loadViewModels(start: newValue, context: context)
            }
        }
    }
}
extension EnvironmentValues {
    struct FacilitiesFilterKey: EnvironmentKey {
        static var defaultValue: Facilities {
            return .empty
        }
    }
    var facilitiesFilter: Facilities {
        get { self[FacilitiesFilterKey.self] }
        set { self[FacilitiesFilterKey.self] = newValue }
    }
}

