//
//  TripRouteForm.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/7/25.
//

import SwiftUI
import FoundationUI
import SwiftData
import FoundationSalt
import MapKit

struct TripRouteForm: View {
    @Binding var model: TripRouteViewModel
    @State private var live: LiveRoute = .init()
    @Environment(\.modelContext) private var context
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                List {
                    ZeroHeaderSection {
                        HarbourPicker("Start", value: $model.start)
                            .swipeActions {
                                Button(systemImage: "trash") {
                                    model.clear()
                                }
                                .tint(.red)
                            }
                        TripDestinationPicker(model: $model)
                        TripRouteStats(model: live)
                    }
                    .seaSection()
                }
                .listStyle(.grouped)
                .zeroListHeader(10)
                .frame(height: 200)
                TripRouteMap(model: model, live: live)
//                    .listRowInsets(.init())
//                    .frame(height: max(100, geo.size.height - 100))
            }
        }
        .onChange(of: model.start) { oldValue, newValue in
            if newValue != nil {
                model.update(context: context)
            }
        }
        .navigationTitle("Trip Route")
        .navigationBarTitleDisplayMode(.inline)
    }
}


extension TripRouteForm {
    @Observable
    final class LiveRoute {
        var start: Harbour?
        var end: Harbour?
        var route: RouteSnippet?
        func load(_ model: TripRouteViewModel, context: ModelContext) async {
            route = model.route
            start = Harbour.find(model.start, in: context)
            end = Harbour.find(model.destination, in: context)
        }
        private var points: [any Mappable] {
            ((route?.points ?? []) + [start, end]).compactMap { $0 }
        }
        var region: MKCoordinateRegion {
            .fitting(points: points)
        }
        var length: Double? {
            route?.distance ?? start?.distance(to: end).converted(to: .nauticalMiles).value
        }
        var bearing: Measurement<UnitAngle>? {
            guard let start,
                  let end
            else { return nil }
            return end.bearing(from: start)
        }
        var count: Int {
            (route?.points.count ?? 1) - 1
        }
    }
}
