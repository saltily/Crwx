//
//  WaypointDeduplicationMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/16/25.
//

import SwiftUI
import MapKit
import SwiftData
import FoundationUI
import FoundationSalt
import os
import WxSalt

struct WaypointDeduplicationButton: View {
    var body: some View {
        NavigationLink(destination: WaypointDeduplicationMap()) {
            Label("Deduplicate Waypoints", systemImage: "arrow.trianglehead.merge")
        }
    }
}
struct WaypointDeduplicationMap: View {
    @State private var legs: [RouteSnippet] = []
    @State private var clusters: [RouteSnippet] = []
    @State private var currentCluster: Int?
    @State private var region: MKCoordinateRegion = .MaineCoast // when this is .init() it screws with minimum chart zoom, not sure why
    @AppStorage(.deduplicationThresholdKey) private var threshold: Double = 250
    @AppStorage(.preferChartMapKey) private var showCharts = true
    @Environment(\.modelContext) private var context
    @State private var task: Task<([RouteSnippet], [RouteSnippet]),Error>?
    var body: some View {
        ZStack {
            SafeChartMap(region: $region) {
                if let currentCluster {
                    let cluster = clusters[currentCluster]
                    ForEach(cluster.points) { wp in
                        TrackDot(wp)
                        if let _ = wp.symbol?.systemImage {
                            MapMarker(wp, defaultTint: .red)
                        }
                    }
                }
                ForEach(legs) { leg in
                    Polyline(leg.points, tint: .gray, thickness: 1)
                }
            } legacy: { map in
                map.lines(legs.map { $0.points }, .gray, thickness: 1)
                if let currentCluster {
                    let cluster = clusters[currentCluster]
                    for wp in cluster.points {
                        if let image = wp.symbol?.systemImage {
                            map.marker(point: wp, systemImage: image, tint: wp.symbol?.colour ?? .red)
                        } else {
                            map.dot(wp, tint: .night, width: 5, border: 1)
                        }
                    }
                }
            }
            Group {
                Button {
                    if let currentCluster,
                       clusters[currentCluster].points.count > 2
                    {
                        let closest = clusters[currentCluster].points.filter {
                            $0.distance(to: region.center).converted(to: .meters).value < 3
                        }
                        if closest.count == 1,
                           let i = clusters[currentCluster].points.firstIndex(where: {
                               $0.id == closest[0].id
                           })
                        {
                            clusters[currentCluster].points.remove(at: i)
                        }
                    }
                } label: {
                    Image(systemName: "scope")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                Text(region.center, format: .location.precision(.fractionLength(5)))
                    .font(.footnote)
                    .fontWeight(.medium)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .foregroundStyle(showCharts ? .black : .primary)
            .tint(showCharts ? .black : .primary)
        }
        .navigationTitle("Deduplicate Waypoints")
        .toolbarTitleDisplayMode(.inline)
        .task {
            await refresh()
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                HStack {
                    Button(systemImage: "chevron.left") {
                        if currentCluster == 0 {
                            currentCluster = nil
                        } else if let currentCluster {
                            self.currentCluster = currentCluster - 1
                        } else {
                            currentCluster = clusters.count - 1
                        }
                        zoomMap()
                    }
                    Spacer()
                    Text(clusters.count.appending("cluster", "clusters") + " to review.")
                    Spacer()
                    Button(systemImage: "chevron.right") {
                        if let currentCluster {
                            if currentCluster < (clusters.count - 1) {
                                self.currentCluster = currentCluster + 1
                            } else {
                                self.currentCluster = nil
                            }
                        } else {
                            currentCluster = 0
                        }
                        zoomMap()
                    }
                }
                .buttonStyle(.bordered)
                HStack {
                    if let currentCluster {
                        Text(currentCluster + 1, format: .number)
                        let cluster = clusters[currentCluster]
                        Button {
                            let container = context.container
                            let waypoints = cluster.points.map { $0.id }
                            let location = region.center
                            Task {
                                do {
                                    let actor = RouteLoader(modelContainer: container)
                                    try await actor.fuse(waypoints: waypoints, to: location)
                                    await refresh()
                                    self.currentCluster = currentCluster == 0 ? nil : currentCluster - 1
                                } catch {
                                    logger.critical("Issue merging waypoints: \(error)")
                                }
                            }
                        } label: {
                            Text("Merge \(cluster.points.count) Waypoints")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Text(threshold, format: .number.precision(.fractionLength(0))) + Text(" ft")
                    Stepper("Threshold", value: $threshold, step: 50)
                        .labelsHidden()
                        .onChange(of: threshold) { oldValue, newValue in
                            Task {
                                await refresh()
                            }
                        }
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
        }
    }
    private func zoomMap() {
        if let currentCluster {
            region = .fitting(points: clusters[currentCluster].points, minimum: 0)
        } else {
            region = .fitting(points: legs.flatMap { $0.points })
        }
    }
    private func refresh() async {
        task?.cancel()
        let container = context.container
        let threshold = threshold
        let task = Task.detached {
            let actor = RouteLoader(modelContainer: container)
            let legs = try await actor.allLegs().sorted()
            let clusters = try await actor.deduplicationCandidates(threshold: threshold)
            return (legs, clusters)
        }
        self.task = task
        do {
            let (legs, clusters) = try await task.value
            self.legs = legs
            self.clusters = clusters
            zoomMap()
        } catch {
            logger.critical("Error loading all routes or deduplication candidates: \(error)")
        }
    }
}

#Preview {
    WaypointDeduplicationMap()
}

extension String {
    static let deduplicationThresholdKey = "com.saltily.Mewx.deduplicationThresholdKey" // Double
}
