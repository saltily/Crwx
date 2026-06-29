//
//  TaskItemViewModel.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/28/26.
//

import Foundation

/// These can be quickly built from a list of strings.  They can be any custom string step instruction.  Or they can be predefined types like checklists.
struct TaskItemViewModel: ExpressibleByStringLiteral, Codable, Sendable, Equatable {
    // also probably conform to identifiable with a unique uuid
    var type: TaskType
    var subTasks: [TaskItemViewModel] = []
    var supplies: [PackingItemViewModel] = []
}


extension TaskItemViewModel {
    init(stringLiteral value: String) {
        type = .custom(value)
    }
    init(_ label: String, _ subTasks: [TaskItemViewModel], supplies: [PackingItemViewModel] = []) {
        self.type = .custom(label)
        self.subTasks = subTasks
        self.supplies = supplies
    }
    init(_ label: String, supplies: [PackingItemViewModel]) {
        self.type = .custom(label)
        self.supplies = supplies
    }
}
