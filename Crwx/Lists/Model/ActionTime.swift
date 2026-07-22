//
//  ShiftTime.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/16/26.
//

import Foundation
import FoundationSalt

/// Lets me know whether to advance or shift the status of something waiting to be packed.
/// And can also apply to tasks and whether to include them in lists.
enum ActionTime: Hashable, Codable, Sendable {
  case never, anytime, on(Date), before(Date), after(Date)
}

extension ActionTime {
    var summary: String {
        switch self {
        case .never: "never"
        case .anytime: "anytime"
        case .on(let date):
            "on \(date.formatted(.dateTime.month(.defaultDigits).day()))"
        case .before(let date):
            "before \(date.formatted(.dateTime.month(.defaultDigits).day()))"
        case .after(let date):
            "after \(date.formatted(.dateTime.month(.defaultDigits).day()))"
        }
    }
    var date: Date? {
        switch self {
        case .never, .anytime: nil
        case .on(let d), .before(let d), .after(let d): d
        }
    }
    var isDue: Bool {
        switch self {
        case .never: return false
        case .anytime: return true
        case .on(let date), .after(let date):
            return .now > date.withoutTime
        case .before(let date):
            return .now < date.withoutTime
//        case .after(let date):
//            return .now > date.withoutTime.tomorrow
        }
    }
}
