//
//  PackedStatus.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation

/// Tells me where something currently is, it's current state, and where to advance it to next.
enum PackedStatus: String, Codable, Sendable {
    case purchase, prep
    case shoreOnHand, packed
    case loadedOnBoat
}


extension PackedStatus {
    /// Replaces this with the next status we would shift to.
    /// Normally on hand goes next to being packed into a bag and then loaded onto the boat.  Optionally indicate to skip packing if you want it to go straight to the boat without checking off as packed into a bag.
    /// I'd consider packing to come ashore but then it wouldn't know which direction the packed items are going, and seems that the boat being smaller, it's much easier to ensure that bags come ashore.
    mutating func advance(skipPacking: Bool = false) {
        switch self {
        case .purchase: self = .shoreOnHand
        case .prep: self = .shoreOnHand
        case .shoreOnHand: self = skipPacking ? .loadedOnBoat : .packed
        case .packed: self = .loadedOnBoat
        case .loadedOnBoat: self = .shoreOnHand
        }
    }
    func adding(state: CheckedState) -> Self {
        if state == .unchecked { return self }
        switch self {
        case .purchase, .prep, .packed, .loadedOnBoat: return .shoreOnHand
        case .shoreOnHand:
            return state == .halfchecked ? .packed : .loadedOnBoat
        }
    }
    static var takeOut: Self { .shoreOnHand }
    static var bringIn: Self { .loadedOnBoat }
    var isPacked: Bool { self == .packed }
    /// As in "wait to load" or "load anytime".
    var thisVerb: String {
        switch self {
        case .purchase: "purchase"
        case .prep: "prep"
        case .shoreOnHand: "load"
        case .packed: "load"
        case .loadedOnBoat: "offload"
        }
    }
}
