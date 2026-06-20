//
//  ChartMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import SwiftUI
import MapKit
import FoundationUI

struct ChartMap: View {
    /// Region is listen only right now
    init(region: Binding<MKCoordinateRegion> = .constant(.init()), builder: @escaping (MapBasket) -> () = { _ in }) {
        _region = region
        self.builder = builder
    }
    @Binding var region: MKCoordinateRegion
    private let builder: (MapBasket) -> ()
    @Environment(\.mapType) private var mapType
    var body: some View {
        UIMap(region: $region) { map in
            builder(map)
        }
        .mapType(mapType.isTiled ? mapType : .noaa)
        .environment(\.colorScheme, .light)
        .northUp()
        .mapAltitudeRange(.tile(zoom: 16)...750_000)
        .showZoomScale()
    }
}

extension String {
    static let preferChartMapKey = "com.saltily.FoundationUI.preferChartMapKey" // Bool
    static let preferredMapTypeKey = "com.saltily.FoundationUI.preferredMapTypeKey" // MapType(rawValu: Int)
}
struct SafeChartMap<Content>: View where Content: MapContent {
    init(region: Binding<MKCoordinateRegion>? = nil, @MapContentBuilder mapContent: @escaping () -> Content, legacy builder: @escaping (MapBasket) -> () = { _ in }) {
        self.regionBinding = region
        self.mapContent = mapContent
        self.builder = builder
    }
    private let regionBinding: Binding<MKCoordinateRegion>?
    private let builder: (MapBasket) -> ()
    @ViewBuilder var mapContent: () -> Content
    @AppStorage(.preferredMapTypeKey) private var mapType: MapType = .noaa
    var body: some View {
        SwapCondition(mapType.isTiled) {
            ChartMap(
                region: regionBinding ?? .constant(.init()),
                builder: mapType.isTiled ? builder : { _ in }
            )
            .mapTypeControl($mapType, region: regionBinding?.wrappedValue)
            .preferredColorScheme(.light)
        } off: {
            SaltMap(region: regionBinding, animates: !mapType.isTiled) {
                mapContent()
            }
            .northUp()
            .mapTypeControl($mapType, region: regionBinding?.wrappedValue)
        }
    }
}
