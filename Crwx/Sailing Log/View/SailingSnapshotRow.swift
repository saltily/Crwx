//
//  SailingSnapshotRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/13/25.
//

import SwiftUI
import FoundationUI
import CoreLocation
import WxSalt
import FoundationSalt

struct SailingSnapshotRow: View {
    let start: Date?
    let route: RouteSnippet?
    let startHarbour: Harbour?
    let endHarbour: Harbour?
    @State var model: SailingSnapshotViewModel?
    @State private var isExpanded = true
    @PositionTracker private var tracker
    @Environment(\.anchorageSetter) private var setter
    @State private var anchorageSetter: TripDestinationPicker.Destination = .init()
    var body: some View {
        HStack {
            if let model {
                NavigationLink(destination: SailingSnapshotForm(model: model, isExpanded: $isExpanded).seaBackground().environment(\.anchorageSetter, anchorageSetter)) {
                    SailingSnapshotSummary(model: model)
                }
                .followMe(model)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            anchorageSetter = .init { anchorage in
                if let route = anchorage.route {
                    model?.set(route: route)
                }
                setter?.save(anchorage)
            }
        }
        .onChange(of: start, initial: true) { oldValue, newValue in
            Task { await refresh() }
        }
        .onChange(of: route) { oldValue, newValue in
            Task { await refresh() }
        }
        .swipeActions(edge: .leading) {
            Button(systemImage: "arrow.clockwise") {
                Task {
                    await refresh()
                }
            }
            .tint(.accentColor)
        }

        
    }
    private func refresh() async {
        guard let start,
              let route,
              let startHarbour,
              let endHarbour,
              let loc = await tracker.currentLocation
        else { return }
//        let loc = CLLocationCoordinate2D(latitude: 44.6672, longitude: -67.3373)
//        let time = start.addingTimeInterval(1.57.hour)
        if let model {
            model.refresh(time: .now, location: loc)
        } else {
            model = .init(startTime: start, route: route, startHarbour: startHarbour, endHarbour: endHarbour, currentLocation: loc, currentTime: .now)
        }
    }
}
