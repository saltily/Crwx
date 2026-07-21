//
//  CheckedState.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import Foundation

enum CheckedState: Equatable {
    case unchecked, halfchecked, checked
}

extension CheckedState {
    /// To treat it as a boolean to toggle - no half state.
    var isChecked: Bool {
        get { self == .checked }
        set {
            if newValue != isChecked {
                self = newValue ? .checked : .unchecked
            }
        }
    }
    /// To treat it as going through all three states.
    mutating func advance() {
        switch self {
        case .unchecked:
            self = .halfchecked
        case .halfchecked:
            self = .checked
        case .checked:
            self = .unchecked
        }
    }
}
