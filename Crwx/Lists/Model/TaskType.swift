//
//  TaskType.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/28/26.
//

import Foundation

enum TaskType: Codable, Sendable, Equatable {
    case custom(String)
    case checklist(Checklist)
}


extension TaskType {
    var label: String {
        switch self {
        case .custom(let string):
            return string
        case .checklist(let checklist):
            return checklist.label
        }
    }
}
