//
//  PotentialAnchorages.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/28/25.
//

import Foundation
import SwiftData
import FoundationSalt
import os

@MainActor
@Observable
final class PotentialAnchorages {
    init(container: ModelContainer) {
        self.engine = .init(modelContainer: container)
    }
    var isLoading = false
    var contents: [AnchoragePotential] = []
    var error: Error?
    let engine: Engine
    private var task: Task<[AnchoragePotential],Error>?
}

// MARK: Filtering
extension PotentialAnchorages {
    func matching(_ intent: VoyageIntent) -> [AnchoragePotential] {
        contents.filter {
            $0.eta <= intent.preferredArrival &&
            $0.quadrantsFromStart.contains(intent.directionOfTravel)
        }
    }
}

// MARK: Loading
extension PotentialAnchorages {
    func loadAnchorages(intent: VoyageIntent, destinations: [HarbourViewModel]) {
        task?.cancel()
        isLoading = true
        let engine = self.engine
        let task = Task.detached {
            try await engine.loadAnchorages(intent: intent, destinations: destinations)
        }
        self.task = task
        Task {
            do {
                contents = try await task.value.sorted(by: \.eta)
                isLoading = false
            } catch {
                isLoading = false
                self.error = error
                logger.critical("Couldn't load potential anchorages: \(error)")
            }
        }
    }
}
extension PotentialAnchorages {
    @ModelActor
    final actor Engine {
        let forecasts: CoastalForecasts = .init()
        func loadAnchorages(intent: VoyageIntent, destinations: [HarbourViewModel]) async throws -> [AnchoragePotential] {
            try await destinations.asyncMap {
                try await potential(destination: $0, intent: intent)
            }.compactMap { $0 }
        }
    }
}
