//
//  SailingSnapshotForm.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/13/25.
//

import SwiftUI
import FoundationUI
import MapKit

// this will also need additional information for clicking through to harbours and anchorages, similar to the ``TripRouteViewModel`` and ``TripRouteForm.LiveRoute``
struct SailingSnapshotForm: View {
    @Bindable var model: SailingSnapshotViewModel
    @Binding var isExpanded: Bool
    var body: some View {
        GeometryReader { geometry in
            ExpandableSplitView(topCollapsedHeight: geometry.size.height / 2, bottomCollapsedHeight: 60, isExpanded: $isExpanded) {
                SailingSnapshotMap(model: model)
            } bottom: {
                if isExpanded {
                    SailingSnapshotDetails(model: model)
                } else {
                    SailingSnapshotOneLine(model: model)
                }
            }
            .navigationTitle(model.route.name)
            .toolbar {
                ToolbarItem {
                    TripNewDestinationButton(model: model)
                }
            }
        }
    }
}



struct SailingSnapshotOneLine: View {
    @Bindable var model: SailingSnapshotViewModel
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                (Text(model.dtg, format: .number.precision(.fractionLength(1))) + Text(" nm"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("DTG").foregroundStyle(.secondary).font(.caption)
            }
            Spacer()
            VStack {
                if let spd = model.spd {
                    (Text(spd, format: .number.precision(.fractionLength(1))) + Text(" kts"))
                } else {
                    Text("3.0 kts")
                        .redacted(reason: .placeholder)
                }
                Text("SPD").foregroundStyle(.secondary).font(.caption)
            }
            Spacer()
            VStack {
                CurrentTideView(time: model.currentTime, location: model.currentLocation)
                Text("TIDE").foregroundStyle(.secondary).font(.caption)
            }
        }
        .padding(.horizontal)
    }
}

fileprivate struct SailingSnapshotDetails: View {
    @Bindable var model: SailingSnapshotViewModel
    var body: some View {
        ScrollView {
            SailingSnapshotSummary(model: model)
                .padding(.top, 10)
            Divider()
            HStack {
                Text("Trip Miles")
                TextField(model.mmg.formatted(.number.precision(.fractionLength(1))), value: $model.tripMiles, format: .number.precision(.fractionLength(0...1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            Divider()
            HStack {
                Text("SOG")
                let sog = model.computedSog?.formatted(.number.precision(.fractionLength(1)))
                Text("est \(sog ?? "--") kts")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                TextField(sog ?? "--", value: $model.sog, format: .number.precision(.fractionLength(0...1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.horizontal)
        .scrollDismissesKeyboard(.interactively)
    }
}

