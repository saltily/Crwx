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
    enum S: Equatable {
        case takeOut, bringIn, dockside, purchase, prep
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.style == rhs.style
    }
}

extension PackingFilter {
    static var takeOut: Self {
        .init(style: .takeOut) { item in
            item.state.status.isIn(.takeOut, .packed)
        }
    }
    static var bringIn: Self {
        .init(style: .bringIn) { item in
            item.state.status == .bringIn
        }
    }
    static var dockside: Self {
        .init(style: .dockside) { item in
            item.configuration.requiresDockside
        }
    }
    static var purchase: Self {
        .init(style: .purchase) { item in
            item.state.status == .purchase
        }
    }
    static var prep: Self {
        .init(style: .prep) { item in
            item.state.status == .prep
        }
    }
}
