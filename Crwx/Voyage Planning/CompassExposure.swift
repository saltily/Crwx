//
//  CompassExposure.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/20/25.
//

import SwiftUI
import FoundationSalt
import FoundationUI

struct CompassExposure: nonisolated Codable, Equatable {
    var contents: [CompassDirection: Level] = [:]
    subscript(direction: CompassDirection) -> Level? {
        get { contents[direction] }
        set { contents[direction] = newValue }
    }
}

// MARK: Text Description
extension CompassExposure {
    var sentence: String {
        // Idea is don't mention the yellows or blanks.
        // If single green or red, just that direction
        // if 2 greens or reds, then both of those
        // if 1/3/5 greens or reds then the middle region
        // if 4 greens or reds then the two quadrants they span
        
        // Protected from westerlies and northest.
        // Protected from southwest.
        // Exposed to the north and southeast.
        fatalError()
    }
}

// MARK: Filter to Cared About Directions
extension CompassExposure {
    /// Erases levels not included in the directions we're interested in
    func filtering<C>(_ directions: C) -> CompassExposure where C: Collection, C.Element == CompassDirection {
        .init(contents: directions.reduce(into: [:], { partialResult, direction in
            partialResult[direction] = contents[direction]
        }))
    }
    /// Erases levels not included in the directions we're interested in
    func filtering(_ directions: CompassDirection...) -> CompassExposure {
        self.filtering(directions)
    }
    /// Safe means we're not expexting much wind anyway, so downgrade any reds to yellows
    func safe() -> CompassExposure {
        .init(contents: contents.reduce(into: [:], { partialResult, kv in
            let (key, value) = kv
            partialResult[key] = value == .exposed ? .some : value
        }))
    }
    mutating func downgrade(_ direction: CompassDirection) {
        if self[direction] == .some {
            self[direction] = .exposed
        }
    }
    mutating func upgrade(_ direction: CompassDirection) {
        if self[direction] == .some {
            self[direction] = .protected
        } else if self[direction] == .exposed {
            self[direction] = .some
        }
    }
    mutating func safe(_ direction: CompassDirection) {
        self[direction] = .protected
    }
}

// MARK: Exposure Level
extension CompassExposure {
    enum Level: Int, Equatable, Codable {
        case protected, some, exposed
        var colour: Color {
            switch self {
            case .protected:
                    .green
            case .some:
                    .orange
            case .exposed:
                    .red
            }
        }
        var boldColour: Color {
            switch self {
            case .protected:
                    .green.mix(with: .black, by: 0.1).mix(with: .blue, by: 0.1)
            case .some:
                    .orange.mix(with: .black, by: 0.1)
            case .exposed:
                    .red.mix(with: .black, by: 0.4)
            }
        }
        var name: String {
            switch self {
            case .protected:
                "Protected"
            case .some:
                "Some Protection"
            case .exposed:
                "Exposed"
            }
        }
        static var warning: Self { .some }
        static var danger: Self { .exposed }
        static var redLight: Self { .exposed }
        static var greenLight: Self { .protected }
        var nilIfGreen: Self? {
            self == .greenLight ? nil : self
        }
    }
    var worst: Level? {
        contents.values.worst
    }
}
extension Collection where Element == CompassExposure.Level {
    var worst: CompassExposure.Level? {
        self.sorted(by: \.rawValue).last
    }
}


// MARK: Code Creation
extension CompassExposure {
    init(protected: [CompassDirection] = [], exposed: [CompassDirection] = []) {
        protected.forEach {
            self[$0] = .protected
        }
        exposed.forEach {
            self[$0] = .exposed
        }
    }
    init(protected: CompassDirection...) {
        self.init(protected: protected)
    }
    init(exposed: CompassDirection...) {
        self.init(exposed: exposed)
    }
    init(protected: CompassDirection..., exposed: CompassDirection...) {
        self.init(protected: protected, exposed: exposed)
    }
}

protocol ExposureLegend {
    func description(for level: CompassExposure.Level) -> String?
}
