//
//  PackingFilter.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import Foundation
import FoundationSalt

struct PackingFilter: Equatable {
    let style: Style
    var _matches: (_ item: PackableItem) -> Bool
    var checkedState: (_ item: PackableItem) -> CheckedState
    var countSentence: (Int) -> String
    var new: () -> PackableItem
    /// Depends on the filter.  Most this is fixed, but for dockside it's the current status of the item.
    var uncheckedStatus: (_ item: PackableItem) -> PackedStatus
    /// Completed after the given date, so I can decide how recent in one spot.
    var _recentlyCompleted: (_ item: PackableItem, _ previousStatus: PackedStatus) -> Bool
    enum Style: Int {
        case takeOut, bringIn, dockside, purchase, prep
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.style == rhs.style
    }
}
extension PackingFilter {
    private var recentAge: TimeInterval { -10.minute }
    func matches(_ item: PackableItem) -> Bool {
        item.isDue && _matches(item)
    }
    func recentlyCompleted(_ item: PackableItem) -> Bool {
        guard let shift = item.lastShift,
              shift.date.timeIntervalSinceNow > recentAge
        else { return false }
        return _recentlyCompleted(item, shift.previousStatus)
    }
}

extension PackingFilter {
    static var takeOut: Self {
        .init(style: .takeOut) { item in
            item.state.status.isIn(.takeOut, .packed)
        } checkedState: { item in
            switch item.state.status {
            case .packed: .halfchecked
            case .loadedOnBoat: .check
            default: .unchecked
            }
        } countSentence: { i in
            "\(i) unpacked \(i.echo("item", "items"))"
        } new: {
            .init("", status: .takeOut)
        } uncheckedStatus: { _ in
                .shoreOnHand
        } _recentlyCompleted: { item, previousStatus in
            previousStatus.isIn(.takeOut, .packed) &&
            item.state.status == .loadedOnBoat
        }
    }
    static var bringIn: Self {
        .init(style: .bringIn) { item in
            item.state.status == .bringIn
        } checkedState: { item in
            switch item.state.status {
            case .loadedOnBoat: .unchecked
            default: .check
            }
        } countSentence: { i in
            "\(i) unpacked \(i.echo("item", "items"))"
        } new: {
            .init("", status: .bringIn)
        } uncheckedStatus: { _ in
                .loadedOnBoat
        } _recentlyCompleted: { item, previousStatus in
            previousStatus == .bringIn &&
            item.state.status == .takeOut
        }
    }
    static var dockside: Self {
        .init(style: .dockside) { item in
            item.configuration.requiresDockside
        } checkedState: { item in
                .unchecked
        } countSentence: { i in
            "\(i) unpacked \(i.echo("item", "items"))"
        } new: {
            .init("", status: .takeOut, configuration: .dockside)
        } uncheckedStatus: { item in
            item.state.status
        } _recentlyCompleted: { item, previousStatus in
            previousStatus.isIn(.bringIn, .takeOut)
        }
    }
    static var purchase: Self {
        .init(style: .purchase) { item in
            item.state.status == .purchase
        } checkedState: { item in
            switch item.state.status {
            case .purchase: .unchecked
            default: .check
            }
        } countSentence: { i in
            "\(i.appending("item", "items")) to purchase"
        } new: {
            .init("", status: .purchase)
        } uncheckedStatus: { _ in
                .purchase
        } _recentlyCompleted: { item, previousStatus in
            previousStatus == .purchase &&
            item.state.status == .takeOut
        }
    }
    static var prep: Self {
        .init(style: .prep) { item in
            item.state.status == .prep
        } checkedState: { item in
            switch item.state.status {
            case .prep: .unchecked
            default: .check
            }
        } countSentence: { i in
            "\(i.appending("item", "items")) to prep"
        } new: {
            .init("", status: .prep)
        } uncheckedStatus: { _ in
                .prep
        } _recentlyCompleted: { item, previousStatus in
            previousStatus == .prep &&
            item.state.status == .takeOut
        }
    }
}


// MARK: Filter Style
extension PackingFilter.Style {
    var halfState: Bool {
        switch self {
        case .takeOut: true
        default: false
        }
    }
    var moveToOptions: [Self] {
        switch self {
        case .takeOut: [.purchase, .prep, .bringIn]
        case .bringIn: [.purchase, .prep, .takeOut]
        case .dockside: []
        case .purchase: [.prep, .takeOut, .bringIn]
        case .prep: [.purchase, .takeOut, .bringIn]
        }
    }
    var listingPath: ListingPath {
        switch self {
        case .takeOut: .takeOut
        case .bringIn: .bringIn
        case .dockside: .dockside
        case .purchase: .purchase
        case .prep: .prepAshore
        }
    }
    var status: PackedStatus {
        switch self {
        case .takeOut, .dockside: .takeOut
        case .bringIn: .bringIn
        case .purchase: .purchase
        case .prep: .prep
        }
    }
}
