//
//  EventRelativeSentence.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 5/8/25.
//

import SwiftUI
import FoundationSalt

struct EventRelativeSentence<Else>: View where Else: View {
    let location: Coordinate?
    @ViewBuilder var `else`: (Coordinate) -> Else
    @Environment(\.tripMapper) private var trip
    var body: some View {
        if let location,
           let start = trip?.start
        {
            let distance = start.distance(to: location).converted(to: .nauticalMiles).value
            let bearing = location.bearing(from: start).compassDirection
            Text(distance, format: .number.precision(.fractionLength(0...1)))
            + Text(" nm ") + Text(bearing.abbreviation)
            + Text(" of ") + Text(start.name?.removingTimestamp() ?? "--")
        } else if let location {
            self.else(location)
        }
    }
}
extension EventRelativeSentence where Else == EmptyView {
    init(location: Coordinate?) {
        self.init(location: location) { _ in
            EmptyView()
        }
    }
}
fileprivate extension String {
    func removingTimestamp() -> String {
        var pieces = self.components(separatedBy: " - ")
        pieces.removeFirst()
        return pieces.joined(separator: " - ")
    }
}

