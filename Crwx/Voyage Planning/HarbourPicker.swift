//
//  HarbourPicker.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/28/25.
//

import SwiftUI
import SwiftData
import FoundationUI
import MapKit
import FoundationSalt

// let's navigate into a searchable map
struct HarbourPicker: View {
    init(_ label: String, value: Binding<UUID>, center: (any Mappable)? = nil) {
        self.label = label
        self._value = value
        self._optionalValue = .constant(nil)
        self.center = center
    }
    init(_ label: String, value: Binding<UUID?>, center: (any Mappable)? = nil) {
        self.label = label
        self._value = .constant(value.wrappedValue ?? .init())
        self._optionalValue = value
        self.center = center
    }
    let label: String
    let center: (any Mappable)?
    @Binding var value: UUID
    @Binding var optionalValue: UUID?
    private var optionalSelection: Binding<UUID?> {
        .init {
            optionalValue ?? value
        } set: { newValue in
            optionalValue = newValue
            if let newValue {
                value = newValue
            }
        }
    }
    @Query private var harbours: [Harbour]
    var body: some View {
        let selectedHarbour = harbours.first(where: { $0.id == value })
        NavigationLink(destination: HarbourPickerMap(selection: optionalSelection, harbours: harbours, initialRegion: .init(center: selectedHarbour ?? center ?? CLLocation.default, diameter: .init(value: 10, unit: .nauticalMiles))).navigationTitle(label)) {
            Text(label)
                .badge(selectedHarbour?.name ?? "")
        }
//        Picker(label, selection: $value) {
//            ForEach(harbours) { harbour in
//                Text(harbour.name).tag(harbour.id)
//            }
//        }
    }
}
// setup a search filter
struct HarbourPickerMap: View {
    @Binding var selection: UUID?
    let harbours: [Harbour]
    let initialRegion: MKCoordinateRegion
    @State private var region: MKCoordinateRegion = .MaineCoast
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    var body: some View {
        SaltMap(region: $region, selection: $selection) {
            ForEach(filteredHarbours) { harbour in
                MapMarker(harbour)
            }
        }
        .northUp()
        .onChange(of: initialRegion, initial: true) { oldValue, newValue in
            Task {
                region = newValue
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            dismiss()
        }
        .searchable(text: $searchText)
        .debounceChange(of: $searchText) { oldValue, newValue in
            if !newValue.isEmpty {
                region = .fitting(points: filteredHarbours)
            } else {
                region = initialRegion
            }
        }
    }
    private var filteredHarbours: [Harbour] {
        guard let searchText = searchText.nilIfEmpty
        else { return harbours }
        return harbours.filter {
            $0.name.localizedStandardContains(searchText)
        }
    }
}
