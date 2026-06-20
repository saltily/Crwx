//
//  PotentialAnchoragesMap.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/28/25.
//

import SwiftUI
import FoundationUI
import MapKit
import FoundationSalt

struct PotentialAnchoragesMap: View {
    let intent: VoyageIntent
    @Bindable var anchorages: PotentialAnchorages
    @State private var region: MKCoordinateRegion = .MaineCoast
    @Environment(\.facilitiesFilter) private var filter
    var body: some View {
        ZStack {
            SaltMap(region: $region) {
                MapDot(intent, tint: .blue, width: 20, border: 3)
                ForEach($anchorages.contents) { $anchorage in
                    if region.contains(anchorage) {
                        if filter(anchorage: anchorage) {
                            AnchorageLink(anchorage: $anchorage, engine: anchorages.engine)
                        } else {
                            AnchorageDot(anchorage: $anchorage, engine: anchorages.engine)
                        }
                    }
                }
            }
            .northUp()
            .showZoomScale()
            if anchorages.isLoading {
                ProgressView()
                    .padding()
                    .mapAlignment(.topLeading)
            }
        }
        .onChange(of: anchorages.contents, initial: true) { oldValue, newValue in
            if oldValue.map({ $0.coordinate }) != newValue.map({ $0.coordinate }) ||
                region == .MaineCoast
            {
                showProspects()
            }
        }
        .onChange(of: intent.preferredArrival) { oldValue, newValue in
            showProspects() // this changes our filter of who is viable
        }
    }
    private var visibleAnchorages: [AnchoragePotential] {
        anchorages.contents.filter {
            region.contains($0)
        }
    }
    private func showProspects() {
        region = .fitting(points: anchorages.matching(intent))
    }
    private func filter(anchorage: AnchoragePotential) -> Bool {
        if filter.isEmpty {
            return anchorage.eta <= intent.preferredArrival &&
               anchorage.quadrantsFromStart.contains(intent.directionOfTravel)
        } else {
            return anchorage.facilities.contains(filter)
        }
    }
}
