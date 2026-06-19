//
//  VoyageLogViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation

struct VoyageLogViewModel {
    // manual
    var events: [VoyageEvent] = []
    
    // information
    let tripIsActive: Bool
    
    var trip: Trip?
}


// MARK: Extended
extension VoyageLogViewModel {
    var isCompleted: Bool { true }
    var isEmpty: Bool {
        events.isEmpty
    }
    mutating func sort() {
        events = events.sorted(by: \.time)
    }
    func save() {
        trip?.update(voyagelog: self)
    }
}


// MARK: Preview
extension VoyageLogViewModel {
    static func preview(in range: ClosedRange<Date> = Date.now.allDay, isActive: Bool = false) -> VoyageLogViewModel {
        .init(events: .random(in: range), tripIsActive: isActive)
    }
}


// MARK: Read from trip
extension Trip {
    var voyagelog: VoyageLogViewModel {
        .init(events: self.events, tripIsActive: !self.isArrived, trip: self)
    }
}

// MARK: Write to trip
extension Trip {
    func update(voyagelog: VoyageLogViewModel) {
        self.events = voyagelog.events
    }
    func revertVoyageLog() {
        self.events = []
    }
}
