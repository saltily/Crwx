//
//  CoastalRegionPicker.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/17/25.
//

import SwiftUI
import FoundationUI

struct CoastalRegionPicker: View {
    @Binding var region: CoastalRegion?
    var body: some View {
        Picker("Coastal Region", systemImage: "line.3.horizontal.decrease.circle", selection: $region) {
            Text("All Regions").tag(nil as CoastalRegion?)
            ForEach(CoastalRegion.allCases) { region in
                Text(region.rawValue).tag(region)
            }
        }
    }
}
struct CoastalRegionPickerMenu: View {
    @Binding var region: CoastalRegion?
    var body: some View {
        Menu(systemImage: "line.3.horizontal.decrease.circle") {
            CoastalRegionPicker(region: $region)
        }
    }
}

#Preview {
    CoastalRegionPicker(region: .constant(.Home))
}
