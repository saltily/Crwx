//
//  AnchorageDot.swift
//  Mewx
//
//  Created by Matthew Goacher on 4/3/25.
//

import SwiftUI
import FoundationUI
import MapKit
import FoundationSalt
import os

struct AnchorageDot: MapContent {
    @Binding var anchorage: AnchoragePotential
    let engine: PotentialAnchorages.Engine
    @State private var task: Task<AnchoragePotential,Error>?
    @Environment(\.anchorageSetter) private var anchorageSetter
    var body: some MapContent {
        Annotation(anchorage.label ?? "", coordinate: anchorage.coordinate) {
            NavigationLink(destination: AnchorageDetail(anchorage: anchorage).environment(\.anchorageSetter, anchorageSetter)) {
                MapDotGlyph(tint: anchorage.colour, width: 10, border: 2)
            }
            .onChange(of: anchorage, initial: true) { oldValue, newValue in
                if !newValue.isLoaded {
                    reload()
                }
            }
        }
    }
    private func reload() {
        task?.cancel()
        let task = Task.detached {
            try await engine.load(anchorage: anchorage)
        }
        self.task = task
        Task {
            do {
                anchorage = try await task.value
            } catch is CancellationError {
                // that's ok, carry on - probably somebody else is coming in behind
            } catch {
                // 'cause cancelling during url request is a different error
                if describing(error).contains("cancelled") { return }
                logger.critical("Could not load anchorage \(error)")
            }
        }
    }
}
