//
//  CheckedRollbackProtocol.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/23/26.
//

import Foundation

protocol CheckedRollbackProtocol {
    associatedtype Rollback
    var uncheckedRollback: Rollback { get }
    func rollback()
}
