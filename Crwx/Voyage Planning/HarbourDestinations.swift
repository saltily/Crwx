//
//  HarbourDestinations.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/28/25.
//

import Foundation
import SwiftData
import FoundationSalt
import os

@Observable
final class HarbourDestinations {
    var viewModels: [HarbourViewModel] = []
    var isLoading = false
    private var task: Task<[HarbourViewModel],Error>?
}

extension HarbourDestinations {
    func loadViewModels(start: UUID, context: ModelContext) {
        guard let start = Harbour.find(start, in: context) else { return }
        task?.cancel()
        isLoading = true
        let container = context.container
        do {
            guard let startId = start.waypoint?.persistentModelID
            else { throw RouteLoader.E.WaypointExpected }
            let harbours: [PersistentIdentifier] = try context.fetch(Harbour.self).compactMap {
                guard $0.id != start.id else { return nil }
                guard let wp = $0.waypoint
                else { throw RouteLoader.E.WaypointExpected }
                return wp.persistentModelID
            }
            Task {
                let task = Task.detached {
                    let actor = RouteLoader(modelContainer: container)
                    return try await harbours.asyncMap {
                        try await actor.harbourViewModel(from: startId, to: $0)
                    }.sorted(by: \.distanceFromStart)
                }
                self.task = task
                do {
                    self.viewModels = try await task.value
                    isLoading = false
                } catch {
                    logger.critical("Couldn't load harbour view models: \(error)")
                    isLoading = false
                }
            }
        } catch {
            logger.critical("Harbours missing their waypoints: \(error)")
            isLoading = false
            return
        }
    }}
