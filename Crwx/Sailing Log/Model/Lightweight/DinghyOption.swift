//
//  DinghyOption.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import FoundationSalt

enum DinghyOption: String, Codable, CaseIterable {
    case none, white, green
}

extension DinghyOption: Identifiable {
    var id: String { self.rawValue }
}

// MARK: Random preview
extension DinghyOption {
    static var random: DinghyOption {
        .randomElement()
    }
}
