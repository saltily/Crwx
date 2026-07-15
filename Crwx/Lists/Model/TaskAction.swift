//
//  TaskAction.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import Foundation

enum TaskAction: String, Codable, Sendable {
    case daysailConfirm, daysailPack, daysailPostConfirm
    case cruiseConfirm, cruiseFood, cruisePersonal, cruiseCleanup, cruisePostConfirm, cruiseChainsaw
}
