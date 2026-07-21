//
//  PackingFilter.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import Foundation
import FoundationSalt

struct PackingFilter: Equatable {
    let style: S
    var matches: (PackableItem) -> Bool
    var checkedState: (PackableItem) -> CheckedState
    var countSentence: (Int) -> String
    var new: () -> PackableItem
    enum S: Equatable {
        case takeOut, bringIn, dockside, purchase, prep
        var halfState: Bool {
            switch self {
            case .takeOut: true
            default: false
            }
        }
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.style == rhs.style
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
        }
    }
}
