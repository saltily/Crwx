//
//  CruiseStopDetail.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/7/25.
//

import SwiftUI
import FoundationSalt

struct CruiseStopDetail: View {
    let day: Day
    let harbour: Harbour
    let route: RouteSnippet?
    let engine: PotentialAnchorages.Engine
    @AnchorageIntent private var intent
    var body: some View {
        let tenDays = 0.0...5.day
        if tenDays.contains(day.start.timeIntervalSinceNow),
           let anchorage
        {
            NestOne(engine: engine, anchorage: anchorage)
        } else {
            HarbourDetail(harbour: harbour)
        }
    }
    private var anchorage: AnchoragePotential? {
        guard let route else { return nil }
        let etd = day.start.addingTimeInterval(9.hour)
        let stayUntil = day.tomorrow.start.addingTimeInterval(10.hour)
        return .init(harbour: harbour, start: .init(route.points[0]), route: route, estimatedSpeed: intent.estimatedSpeed, etd: etd, stayUntil: stayUntil)
    }
}

fileprivate struct NestOne: View {
    let engine: PotentialAnchorages.Engine
    @State var anchorage: AnchoragePotential
    @StateObject private var task = PerformTask<AnchoragePotential>(multiple: .skipsIfRunning)
    var body: some View {
        AnchorageDetail(anchorage: anchorage)
            .onAppear {
                task.perform {
                    try await engine.load(anchorage: anchorage)
                } then: { anchorage in
                    self.anchorage = anchorage
                }
            }
    }
}
