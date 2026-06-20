//
//  CruiseForm.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import FoundationUI
import MapKit
import FoundationSalt
import SwiftData
import os

/// - todo:
///   - This should have both a map and a list view.
struct CruiseForm: View {
    let model: CruiseViewModel
    @Environment(\.modelContext) private var context
    var body: some View {
        NestOne(model: model, context: context)
    }
}
fileprivate struct NestOne: View {
    init(model: CruiseViewModel, context: ModelContext) {
        self.model = model
        self._region = .init(initialValue: model.region)
        self._engine = .init(initialValue: .init(modelContainer: context.container))
    }
    @Bindable var model: CruiseViewModel
    @Environment(\.colorScheme) private var scheme
    @State private var region: MKCoordinateRegion
    @State private var engine: PotentialAnchorages.Engine
    var body: some View {
        let pattern = ColorPattern(model.colours, colorScheme: scheme)
        SaltMap(region: $region) {
            ForEach(model.legs) { leg in
                if leg.mmg > 0 {
                    let tint = pattern[model[leg.id]]
                    if let track = leg.trip?.track {
                        Polyline(track.points, tint: tint, thickness: 2)
                    } else {
                        RoutePolyline(route: leg.route, tint: tint, region: region)
                    }
                    LegAnnotation(leg: leg)
                }
            }
            ForEach(model.anchorages) { anchorage in
                let i = model[anchorage.id]
                if !model.isDuplicate(i) {
                    NavigationMapLink(anchorage.winds.summary, coordinate: anchorage.coordinate, tint: pattern[i])
                    {
                        let leg = (0..<model.legs.count).contains(i) ? model.legs[i] : nil
                        CruiseStopDetail(day: anchorage.id, harbour: anchorage.harbour, route: leg?.route, engine: engine)
                            .cruiseActions(i, model: model, region: $region)
                    } icon: {
                        Text(anchorage.id.start, format: .dateTime.weekday())
                            .fixedSize()
                            .shadow(color: .black.opacity(0.8), radius: 3)
                            .overlay {
                                if !model.canMove(i) {
                                    Image(systemName: "lock.fill")
                                        .font(.caption2)
                                        .opacity(0.8)
                                        .offset(y: 14)
                                }
                            }
                            .offset(y: -2)
                    }
                }
            }
        }
        .northUp()
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    RefreshingButton {
                        await refreshWeather()
                    }
                    .frame(width: 28, height: 40)
                    ColorFamilyPicker($model.colours)
                        .buttonStyle(.automatic)
                        .padding(.trailing, 5)
                    if model.canSetStart {
                        DatePicker("Start", selection: $model.startDate, displayedComponents: .date)
                    } else {
                        Spacer()
                    }
                    AddToCruiseButton(model: model) {
                        region = model.region
                    }
                    .frame(width: 28, height: 40)
                }
                CruiseStats(cruise: model)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 5)
            .background(.thinMaterial)
        }
        .task {
            await refreshWeather()
        }
    }
    private func refreshWeather() async {
        do {
            try await model.refreshWeather()
        } catch {
            logger.critical("Something went wrong fetching the weather: \(error)")
        }
    }
}

fileprivate struct RefreshingButton: View {
    let action: () async -> ()
    @State private var isRefreshing = false
    var body: some View {
        Button {
            isRefreshing = true
            Task {
                await action()
                isRefreshing = false
            }
        } label: {
            if isRefreshing {
                ProgressView()
            } else {
                Image(systemName: "arrow.clockwise")
            }
        }
    }
}
