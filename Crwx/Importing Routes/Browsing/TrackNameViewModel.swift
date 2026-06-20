//
//  TrackNameViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/11/25.
//

import Foundation
import SwiftData

struct TrackNameViewModel: Identifiable, Sendable {
    var persistentId: PersistentIdentifier
    let id: UUID
    var name: String
    var date: Date?
}


extension TrackNameViewModel {
    init(persistentModel: Track) {
        self.persistentId = persistentModel.persistentModelID
        self.id = persistentModel.id
        self.name = persistentModel.name
        self.date = persistentModel.date
    }
}
