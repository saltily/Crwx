//
//  Item.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/19/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
