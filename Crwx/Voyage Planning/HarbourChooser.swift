//
//  HarbourChooser.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/23/25.
//

import SwiftUI
import FoundationUI
import MapKit
import SwiftData

struct HarbourChooser: View {
    @AppStorage(.harbourChooserUseMapKey) private var useMap = true
    @State private var facilitiesFilter: Facilities = .empty
    var body: some View {
        Group {
            // can't use swap condition here or confused by the two searchables
            if useMap {
                HarbourChooserMap()
            } else {
                HarbourChooserList()
            }
        }
        .environment(\.facilitiesFilter, facilitiesFilter)
        .safeAreaInset(edge: .bottom) {
            HStack {
                AnchorageFacilitiesFilterMenu(facilities: $facilitiesFilter)
                Picker("Use Map", selection: $useMap) {
                    Text("Map").tag(true)
                    Text("List").tag(false)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .background(.thinMaterial)
        }
    }
}

#Preview {
    HarbourChooser()
}
extension String {
    static let harbourChooserUseMapKey = "com.saltily.Mewx.harbourChooserUseMapKey" // Bool
}
