//
//  DownloadChartsModifier.swift
//  Mewx
//
//  Created by Matthew Goacher on 8/29/25.
//

import SwiftUI
import FoundationUI

struct DownloadChartsModifier: ViewModifier {
    @Bindable var trip: Trip
    @State private var isLoading = false
    func body(content: Content) -> some View {
        content
            .onChange(of: trip.route) { oldValue, newValue in
                if let newValue {
                    Task {
                        isLoading = true
                        await TileDatabase.charts.preload(newValue.mapTiles)
                        isLoading = false
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Downloading charts…")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
                }
            }
    }
}
extension View {
    func downloadCharts(_ trip: Trip) -> some View {
        modifier(DownloadChartsModifier(trip: trip))
    }
    func downloadCharts(_ cruise: Cruise) -> some View {
        modifier(DownloadCruiseChartsModifier(cruise: cruise))
    }
}
struct DownloadCruiseChartsModifier: ViewModifier {
    @Bindable var cruise: Cruise
    @State private var isLoading = false
    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Downloading charts…")
                }
                .font(.subheadline)
            }
        }
        .onChange(of: cruise.routes) { oldValue, newValue in
            Task {
                isLoading = true
                await TileDatabase.charts.preload(newValue.mapTiles)
                isLoading = false
            }
        }
    }
}
