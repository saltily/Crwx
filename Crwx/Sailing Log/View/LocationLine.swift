//
//  LocationLine.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/7/24.
//

import SwiftUI
import MapKit
import FoundationSalt

struct LocationLine: View {
    let location: LocationSnippet?
    @State private var mapCamera: MapCameraPosition = .automatic
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 8) {
                if let location = location {
                    Text(location.name ?? "no name")
                    Text(location.coordinate, format: .location.minutes(.fractionLength(2)).multiline())
                        .multilineTextAlignment(.center)
                }
                else {
                    Text("No location")
                }
            }
            Spacer()
            if let location = location {
                Map(position: $mapCamera) {
                    Marker("", coordinate: location.coordinate)
                }
            }
            else {
                Color(.secondaryLabel)
            }
        }
        .onAppear {
            centreMap(on: location?.coordinate)
        }
        .onChange(of: location?.coordinate) { oldValue, newValue in
            centreMap(on: newValue)
        }
    }
    private func centreMap(on point: CLLocationCoordinate2D?) {
        if let point {
            mapCamera = .region(.init(center: point, diameter: .init(value: 0.75, unit: .nauticalMiles)))
        }
    }
}

#Preview("Random") {
    List {
        LocationLine(location: .random)
            .frame(height: 120)
    }
}

#Preview("None") {
    List {
        LocationLine(location: nil)
            .frame(height: 120)
    }
}
