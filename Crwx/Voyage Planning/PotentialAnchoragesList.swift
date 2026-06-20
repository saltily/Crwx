//
//  PotentialAnchoragesList.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/29/25.
//

import SwiftUI

struct PotentialAnchoragesList: View {
    let intent: VoyageIntent
    @Bindable var anchorages: PotentialAnchorages
    @Environment(\.facilitiesFilter) private var filter
    var body: some View {
        List {
            Group {
                if anchorages.isLoading {
                    Section { ProgressView() }
                }
                ForEach($anchorages.contents) { $anchorage in
                    if filter(anchorage: anchorage) {
                        AnchorageRow(anchorage: $anchorage, engine: anchorages.engine)
                            .opacity(anchorage.eta <= intent.preferredArrival ? 1 : 0.5)
                    }
                }
            }
            .seaSection()
        }
        .refreshable {
            $anchorages.contents.forEach {
                $0.wrappedValue.isLoaded = false
            }
        }
    }
    private func filter(anchorage: AnchoragePotential) -> Bool {
        if filter.isEmpty {
            return anchorage.quadrantsFromStart.contains(intent.directionOfTravel)
        } else {
            return anchorage.facilities.contains(filter)
        }
    }
}
