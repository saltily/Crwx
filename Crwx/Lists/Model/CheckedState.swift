//
//  CheckedState.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import SwiftUI

enum CheckedState: Equatable {
    case unchecked, halfchecked, checked(Date)
}

extension CheckedState {
    static var check: Self { .checked(.now) }
    /// To treat it as a boolean to toggle - no half state.
    var isChecked: Bool {
        get {
            switch self {
            case .checked: true
            default: false
            }
        }
        set {
            if newValue != isChecked {
                self = newValue ? .check : .unchecked
            }
        }
    }
    var sortValue: Date {
        switch self {
        case .checked(let d): d
        default: .distantFuture
        }
    }
    /// To treat it as going through all three states.
    mutating func advance() {
        switch self {
        case .unchecked:
            self = .halfchecked
        case .halfchecked:
            self = .check
        case .checked:
            self = .unchecked
        }
    }
    var systemImage: String {
        switch self {
        case .unchecked:
            "circle"
        case .halfchecked:
            "circle.tophalf.filled"
        case .checked:
            "checkmark.circle.fill"
        }
    }
    var fontWeight: Font.Weight {
        switch self {
        case .unchecked:
                .thin
        case .halfchecked:
                .light
        case .checked:
                .regular
        }
    }
}
