//
//  AddToCruiseButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import FoundationUI
import MapKit
import SwiftData
import FoundationSalt

struct AddToCruiseButton: View {
    @Bindable var model: CruiseViewModel
    let callback: () -> ()
    @State private var selectedHarbour: UUID?
    @State private var isPresented = false
    @Query private var harbours: [Harbour]
    @Environment(\.modelContext) private var context
    var body: some View {
        Button(systemImage: "plus") {
            selectedHarbour = nil
            isPresented = true
        }
        .navigationDestination(isPresented: $isPresented) {
            HarbourPickerMap(selection: $selectedHarbour, harbours: harbours, initialRegion: initialRegion)
                .navigationTitle("Add Another Stop")
        }
        .onChange(of: selectedHarbour) { oldValue, newValue in
            if oldValue == nil,
               let newValue,
               let new = Harbour.find(newValue, in: context)
            {
                model.add(harbour: new)
                callback()
            }
        }
    }
    private var initialRegion: MKCoordinateRegion {
        if let center = model.anchorages.last {
            return .init(center: center, diameter: .init(value: 10, unit: .nauticalMiles))
        }
        return .default
    }
}
