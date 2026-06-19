//
//  SailingFollowMeModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/8/25.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import CoreLocation

struct SailingFollowMeModifier: ViewModifier {
    @Bindable var model: SailingSnapshotViewModel
    @PositionTracker private var tracker
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @StateObject private var task = PerformTask<CLLocation?>(multiple: .replacesRunning)
    func body(content: Content) -> some View {
        content
            .onReceive(timer) { _ in
                task.perform {
                    await tracker.currentLocation
                } then: { location in
                    if let location {
                        model.refresh(location: location)
                    }
                }
            }
    }
}
extension View {
    func followMe(_ model: SailingSnapshotViewModel) -> some View {
        modifier(SailingFollowMeModifier(model: model))
    }
}
