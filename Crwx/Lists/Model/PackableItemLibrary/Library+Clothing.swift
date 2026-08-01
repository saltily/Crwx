//
//  Library+Clothing.swift
//  Crwx
//
//  Created by Matthew Goacher on 8/1/26.
//

import Foundation


extension PackableItemDefinition {
    static var peaCoat: PackableItemDefinition {
        .init(id: UUID(uuidString: "1059e78e-e5c9-4005-999d-4b4a1bee9558")!, name: "pea coat", category: .clothing, lifecycle: .seasonal, consumable: nil, locker: .aftSettee, requiresDockside: false)
    }
}
