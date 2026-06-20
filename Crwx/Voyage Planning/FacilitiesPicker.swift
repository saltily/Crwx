//
//  FacilitiesPicker.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/22/25.
//

import SwiftUI
import WxSalt

struct FacilitiesPicker: View {
    @Binding var facilities: Facilities
    var body: some View {
        NavigationLink {
            List {
                ForEach(Facility.allCases) { facility in
                    Button {
                        facilities[facility].toggle()
                    } label: {
                        HStack {
                            Label(facility.description, systemImage: facility.systemImage)
                            Spacer()
                            if facilities[facility] {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
                .seaSection()
                .tint(.primary)
            }
            .seaBackground(.darkSeaBlue)
            .navigationTitle("Facilities")
        } label: {
            HStack {
                Text("Facilities")
                Spacer()
                Group {
                    ForEach(facilities.facilities) { facility in
                        Image(systemName: facility.systemImage)
                    }
                    if facilities.isEmpty {
                        Text("None")
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}
