//
//  HubInfo.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/17/25.
//

import SwiftUI
import FoundationUI
import SwiftData
import FoundationSalt
import os

struct HubInfo: View {
    @Bindable var waypoint: Waypoint
    @State private var endpoints: [Waypoint] = []
    @Environment(\.modelContext) private var context
    var body: some View {
        ZeroHeaderSection(20) {
            TextField("Name", text: $waypoint.name)
            Toggle("Is Hub", isOn: $waypoint.isHub)
        }
        Section {
            Text(waypoint.coordinate, format: .location)
            if waypoint.isHarbour {
                Text("Is a harbour.")
            }
            let routes = waypoint.routes ?? []
            Text("Waypoint appears in \(routes.count.appending("route", "routes")).")
            if endpoints.contains(waypoint) {
                Text("This waypoint is an endpoint in some routes.")
            }
            let regions = regions
            if regions.count > 1 {
                let s = regions.sorted().map { $0.rawValue }.formatted(.list(type: .and))
                Text("Connects regions \(s).")
            }
            if !endpoints.isEmpty {
                let s = endpoints.map { $0.name }.formatted(.list(type: .and))
                Text("Connects harbours \(s).")
            }
        }
        .onChange(of: waypoint, initial: true) { oldValue, newValue in
            loadEndpoints()
        }
        Section {
            TextField("Notes", text: $waypoint.notes, axis: .vertical)
                .lineLimit(2...)
        }
    }
    private func loadEndpoints() {
        let container = context.container
        let id = waypoint.id
        let task = Task.detached {
            let actor = RouteLoader(modelContainer: container)
            return try await actor.endpoints(off: id)
        }
        Task {
            do {
                endpoints = try await task.value.compactMap {
                    context.model(for: $0) as? Waypoint
                }.sorted(by: \.longitude)
            } catch {
                logger.critical("Error finding endpoints: \(error)")
            }
        }
    }
    private var regions: Set<CoastalRegion> {
        endpoints.reduce(into: []) { partialResult, wp in
            partialResult.insert(wp.coastalRegion)
        }
    }
}
