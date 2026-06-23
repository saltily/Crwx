//
//  CruisingGuideReader.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/24/25.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import WxSalt

struct CruisingGuideReader: View {
    init(_ label: String, cruisingGuide: Binding<CruisingGuide>) {
        self.label = label
        self.cruisingGuide = cruisingGuide.wrappedValue
        self.mutable = cruisingGuide
    }
    init(_ label: String, cruisingGuide: CruisingGuide) {
        self.label = label
        self.cruisingGuide = cruisingGuide
        self.mutable = nil
    }
    let label: String
    let cruisingGuide: CruisingGuide
    let mutable: Binding<CruisingGuide>?
    @State private var showEditor = false
    var body: some View {
        List {
            Group {
                Section(label) {
                    PlaceholderText(cruisingGuide.summary, placeholder: "No Summary")
                }
                if let activities = cruisingGuide.activities.nilIfEmpty {
                    Section("Things to Do") {
                        Text(activities)
                    }
                }
                if let gettingAshore = cruisingGuide.gettingAshore.nilIfEmpty {
                    Section("Getting Ashore") {
                        Text(gettingAshore)
                    }
                }
                if let anchoring = cruisingGuide.anchoring.nilIfEmpty {
                    Section("Anchorages, Moorings") {
                        Text(anchoring)
                    }
                }
                if let services = cruisingGuide.services.nilIfEmpty {
                    Section("For the Boat / Crew") {
                        Text(services)
                    }
                }
                if let approaches = cruisingGuide.approaches.nilIfEmpty {
                    Section("Approaches") {
                        Text(approaches)
                    }
                }
                if let old = CruisingGuide(decoding: cruisingGuide.cached) {
                    Section {
                        let label = "\(old.year.formatted(.number.grouping(.never))) Cruising Guide"
                        NavigationLink(label, destination: CruisingGuideReader(label, cruisingGuide: old))
                    }
                }
            }
            .seaSection()
            .textCase(nil)
        }
        .font(.subheadline)
        .navigationTitle("Cruising Guide")
        .seaBackground()
        .toolbar {
            if mutable != nil {
                Button("Edit", systemImage: "pencil") {
                    showEditor = true
                }
            }
        }
        .fullScreenCover(isPresented: $showEditor) {
            if let mutable {
                NavigationStack {
                    CruisingGuideEditor(value: mutable)
                        .toolbar {
                            DismissButton()
                                .fontWeight(.bold)
                        }
                        .navigationTitle(label)
                }
            }
        }
    }
}
