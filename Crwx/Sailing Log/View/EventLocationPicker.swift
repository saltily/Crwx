//
//  EventLocationPicker.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 5/7/25.
//

import SwiftUI
import MapKit
import FoundationUI
import FoundationSalt

struct EventLocationPicker: View {
    let label: String
    @Binding var coordinate: Coordinate?
    @State private var region: MKCoordinateRegion = .init()
    var body: some View {
        NavigationLink {
            
            // MARK: Map Picker
            ZStack {
                TripMap(region: $region, marker: coordinate?.labelled(label))
                Button(systemImage: "scope") {
                    coordinate = .make(from: region.center)
                    logger.log("Didn't I set it to \(describing(coordinate))")
                    // navigate back?
                }
                .tint(.darkSeaBlue.mix(with: .white, by: 0.4))
                .font(.title)
            }
            .onChange(of: coordinate, initial: true) { oldValue, newValue in
                if let newValue {
                    region = .init(center: newValue, diameter: .init(value: 1, unit: .nauticalMiles))
                }
            }
            .navigationTitle(label)
            .seaBackground(.darkSeaBlue)
            .safeAreaInset(edge: .bottom) {
                if let coordinate {
                    Text(coordinate.coordinate, format: .location)
                }
            }
            
        } label: {
            
            // MARK: Row
            HStack(spacing: 15) {
                let region: MKCoordinateRegion = if let coordinate {
                    .init(center: coordinate, diameter: .init(value: 0.5, unit: .nauticalMiles))
                } else { .init() }
                TripMap(region: .constant(region), marker: coordinate?.labelled(label))
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .zoomDisabled()
                    .panningDisabled()
                if let coordinate {
                    VStack(alignment: .leading) {
                        Group {
                            Text(coordinate.latitude, format: .latitude.minutes(.fractionLength(3)).labelled())
                            Text(coordinate.longitude, format: .longitude.minutes(.fractionLength(3)).labelled())
                        }
                        .monospaced()
                        EventRelativeSentence(location: coordinate)
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                            .padding(.top, 1)
                    }
                } else {
                    Text("No Location")
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
}
