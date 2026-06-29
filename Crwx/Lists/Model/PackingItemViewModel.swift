//
//  PackingItemViewModel.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/29/26.
//

import Foundation

struct PackingItemViewModel: ExpressibleByStringLiteral, Codable, Sendable, Equatable {
    var label: String
}


extension PackingItemViewModel {
    init(stringLiteral value: String) {
        label = value
    }
}
