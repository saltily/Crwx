//
//  MobileHomeView.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/19/26.
//

import SwiftUI
import WxSalt

struct MobileHomeView: View {
    var body: some View {
        NavigationStack {
            AllTripsView()
                .seaBackground()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MobileHomeView()
}

struct EaseInView: View {
    @State private var station: TideStation = .default
    var body: some View {
        NavigationStack {
            List {
                LocationTideStationPicker(station: $station)
                    .seaSection()
            }
            .navigationTitle("Crwx")
            .seaBackground()
        }
    }
}
