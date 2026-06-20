//
//  HarbourChooserMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/13/25.
//

import SwiftUI
import FoundationUI
import MapKit
import SwiftData
import WxSalt
import FoundationSalt
import os

struct HarbourChooserMap: View {
    @Query private var harbours: [Harbour]
    @State private var region: MKCoordinateRegion = .MaineCoast
    @State private var wasScaled = false
    @CoastRegion private var coastalRegion
    @State private var searchText = ""
    @Environment(\.facilitiesFilter) private var filter
    var body: some View {
        ZStack {
            SaltMap(region: $region) {
                ForEach(visibleHarbours) { harbour in
                    HarbourButton(harbour: harbour, isMatched: searchMatches.contains(harbour))
                }
            }
            ZoomControlsOverlay(region: $region, showAll: .fitting(points: harbours))
        }
        .searchable(text: $searchText)
        .northUp()
        .onAppear {
            if !wasScaled {
                region = .fitting(points: harbours.coastalRegion(coastalRegion ?? .Home))
                wasScaled = true
            }
        }
        .debounceChange(of: $searchText, seconds: 0.5) { newValue in
            focusOnSearch()
        }
        .onSubmit(of: .search) {
            focusOnSearch()
        }
        .onChange(of: region) { oldValue, newValue in
            if region.span.longitudeDelta > 3 {
                coastalRegion = nil
            } else {
                coastalRegion = region.center.coastalRegion
            }
        }
        .onChange(of: coastalRegion) { oldValue, newValue in
            if region.center.coastalRegion != newValue {
                region = .fitting(points: harbours.coastalRegion(newValue))
            }
        }
        .toolbar {
            ToolbarItem {
                CoastalRegionPickerMenu(region: $coastalRegion)
            }
        }
        .navigationTitle("Harbours")
        .navigationBarTitleDisplayMode(.inline)
    }
    private var filtered: [Harbour] {
        guard !filter.isEmpty else { return harbours }
        return harbours.filter {
            $0.facilities.contains(filter)
//            !$0.facilities.intersection(filter).isEmpty
        }
    }
    private var visibleHarbours: [Harbour] {
        filtered.filter {
            region.contains($0)
        }
    }
    private var searchMatches: [Harbour] {
        guard !searchText.isEmpty else { return [] }
        return harbours.filter {
            $0.name.localizedStandardContains(searchText)
        }
    }
    private func focusOnSearch() {
        if let first = searchMatches.first {
            logger.trace("Should be going to the center of \(first.name).")
            region = .init(center: first, diameter: .init(value: 1, unit: .nauticalMiles))
        }
        else {
            logger.trace("Should be going further out")
            region = .fitting(points: harbours.coastalRegion(coastalRegion ?? .Home))
        }
    }
}
fileprivate struct HarbourButton: MapContent {
    let harbour: Harbour
    let isMatched: Bool
    var body: some MapContent {
        NavigationMapLink(harbour, tint: isMatched ? .accentColor : nil, destination: HarbourDetail(harbour: harbour).seaBackground())
    }
}

@propertyWrapper
struct CoastRegion: DynamicProperty {
    @AppStorage(.filterHarboursRegionKey) private var rawValue: String?
    var wrappedValue: CoastalRegion? {
        get { .init(rawValue: rawValue ?? "") }
        nonmutating set { rawValue = newValue?.rawValue }
    }
    var projectedValue: Binding<CoastalRegion?> {
        .init {
            wrappedValue
        } set: { newValue in
            wrappedValue = newValue
        }
    }
}
@propertyWrapper
struct DestinationRegion: DynamicProperty {
    @AppStorage(.filterDestinationsRegionKey) private var rawValue: String?
    var wrappedValue: CoastalRegion? {
        get { .init(rawValue: rawValue ?? "") }
        nonmutating set { rawValue = newValue?.rawValue }
    }
    var projectedValue: Binding<CoastalRegion?> {
        .init {
            wrappedValue
        } set: { newValue in
            wrappedValue = newValue
        }
    }
}

extension String {
    static let filterHarboursRegionKey = "com.saltily.Mewx.filterHarboursRegionKey" // String?
    static let filterDestinationsRegionKey = "com.saltily.Mewx.filterDestinationsRegionKey" // String?
}
