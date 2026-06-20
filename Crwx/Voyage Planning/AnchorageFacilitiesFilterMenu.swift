//
//  AnchorageFacilitiesFilterMenu.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/15/25.
//

import SwiftUI
import FoundationUI

struct AnchorageFacilitiesFilterMenu: View {
    @Binding var facilities: Facilities
    var body: some View {
        Menu(systemImage: "line.3.horizontal.decrease.circle") {
            if !facilities.isEmpty {
                Button("Reset", systemImage: "xmark", role: .destructive) {
                    facilities = .empty
                }
            }
            ForEach(Facility.allCases.reversed()) { facility in
                let isOn = facilities[facility]
                Button {
                    if isOn {
                        facilities.remove(facility.option)
                    } else {
                        facilities.insert(facility.option)
                    }
                } label: {
                    Label {
                        Text(facility.description)
                    } icon: {
                        Image(systemName: isOn ? "checkmark" : facility.systemImage)
                            .tint(isOn ? .green : nil)
                    }
                }
            }
        }
        .symbolVariant(facilities.isEmpty ? .none : .fill)
    }
}
