//
//  WaypointSaveHarbourModifier.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/22/25.
//

import SwiftUI
import SwiftData
import FoundationUI

struct WaypointSaveHarbourModifier: ViewModifier {
    @Bindable var waypoint: Waypoint
    @Environment(\.modelContext) private var context
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading) {
                if waypoint.harbour == nil {
                    Button(systemImage: "square.and.arrow.down") {
                        let new = Harbour(
                            id: waypoint.id,
                            name: waypoint.name,
                            latitude: waypoint.latitude,
                            longitude: waypoint.longitude,
                            notes: ""
                        )
                        context.insert(new)
                        new.waypoint = waypoint
                        waypoint.harbour = new
                        try? context.save()
                    }
                    .tint(.black)
                }
            }
    }
}
extension View {
    func swipeSaveAsHarbour(waypoint: Waypoint) -> some View {
        modifier(WaypointSaveHarbourModifier(waypoint: waypoint))
    }
}
