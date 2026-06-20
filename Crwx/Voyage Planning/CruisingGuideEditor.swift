//
//  CruisingGuideEditor.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/23/25.
//

import SwiftUI

struct CruisingGuideEditor: View {
    @Binding var value: CruisingGuide
    var body: some View {
        List {
            Group {
                Section {
                    TextPicker("Summary", text: $value.summary)
                }
                Section {
                    TextPicker("Approaches", text: $value.approaches)
                    TextPicker("Anchorages, Moorings", text: $value.anchoring)
                }
                Section {
                    TextPicker("Getting Ashore", text: $value.gettingAshore)
                    TextPicker("For the Boat / Crew", text: $value.services)
                    TextPicker("Things to Do", text: $value.activities)
                }
                Section {
                    HStack {
                        Text("Cruising Guide Published")
                            .font(.headline)
                            .fixedSize()
                        Spacer()
                        TextField("1991", value: $value.year, format: .number.grouping(.never))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .seaSection()
        }
        .seaBackground(.darkSeaBlue)
    }
}
