//
//  AnchorageLink.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/29/25.
//

import SwiftUI
import MapKit
import FoundationUI
import FoundationSalt
import WxSalt
import os

struct AnchorageLink: MapContent {
    @Binding var anchorage: AnchoragePotential
    let engine: PotentialAnchorages.Engine
    @Environment(\.modelContext) private var context
    @Environment(\.anchorageSetter) private var anchorageSetter
    var body: some MapContent {
        NavigationMapLink(anchorage.label ?? "", coordinate: anchorage.coordinate, tint: anchorage.colour, destination: AnchorageDetail(anchorage: anchorage).environment(\.anchorageSetter, anchorageSetter)) {
            Icon(anchorage: $anchorage, engine: engine)
        }
    }
}
fileprivate struct Icon: View {
    @Binding var anchorage: AnchoragePotential
    let engine: PotentialAnchorages.Engine
    @State private var isLoading = false
    @State private var error: Error?
    @State private var task: Task<AnchoragePotential,Error>?
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else if error != nil {
                Image(systemName: "exclamationmark.triangle.fill")
            } else if anchorage.darkArrival {
                Image(systemName: "moon.fill")
//            } else if let windExposure = anchorage.windExposure {
//                ExposureSymbol(exposure: windExposure)
            } else {
                AnchorageLink.IconImage(anchorage: anchorage)
//                HStack(spacing: 5) {
//                    VStack(spacing: 0) {
//                        Text(anchorage.distance.rounded, format: .number)
//                            .fixedSize()
//                            .offset(y: 1)
//                        Text("NM")
//                            .opacity(0.6)
//                            .font(.system(size: 9))
//                            .fixedSize()
//                    }
//                    .offset(y: 2)
//                    if let snapshot = anchorage.tideAtArrival {
//                        Image(systemName: snapshot.movement.symbolName)
//                            .frame(width: 5)
//                            .font(.caption2)
//                    }
//                }
//                .font(.footnote)
//            } else if let snapshot = anchorage.tideAtArrival {
//                TideMapIcon(snapshot: snapshot)
//            } else {
//                Image(systemName: "questionmark")
            }
        }
        .onChange(of: anchorage, initial: true) { oldValue, newValue in
            if !newValue.isLoaded {
                reload()
            }
        }
    }
    private func reload() {
        task?.cancel()
        isLoading = true
        error = nil
        let task = Task.detached {
            try await engine.load(anchorage: anchorage)
        }
        self.task = task
        Task {
            do {
                anchorage = try await task.value
                isLoading = false
            } catch is CancellationError {
                // that's ok, carry on - probably somebody else is coming in behind
            } catch {
                // 'cause cancelling during url request is a different error
                if describing(error).contains("cancelled") { return }
                logger.critical("Could not load anchorage \(error)")
                isLoading = false
                self.error = error
            }
        }
    }
}

struct TideMapIcon: View {
    let snapshot: TideSnapshot
    var body: some View {
        HStack(spacing: 5) {
            Text(snapshot.height.converted(to: .feet).value, format: .number.precision(.fractionLength(0...1)))
                .fixedSize()
            Image(systemName: snapshot.movement.symbolName)
                .frame(width: 5)
                .font(.caption2)
        }
        .font(.footnote)
    }
}

extension AnchorageLink {
    struct IconImage: View {
        let anchorage: AnchoragePotential
        @AppStorage(.anchorageLinkIconTypeKey) private var type: IconType = .distance
        var body: some View {
            switch type {
            case .distance:
                HStack(spacing: 5) {
                    VStack(spacing: 0) {
                        Text(anchorage.distance.rounded, format: .number)
                            .fixedSize()
                            .offset(y: 1)
                        Text("NM")
                            .opacity(0.6)
                            .font(.system(size: 9))
                            .fixedSize()
                    }
                    .offset(y: 2)
                    if let snapshot = anchorage.tideAtArrival {
                        Image(systemName: snapshot.movement.symbolName)
                            .frame(width: 5)
                            .font(.caption2)
                    }
                }
                .font(.footnote)
            case .tide:
                if let snapshot = anchorage.tideAtArrival {
                    TideMapIcon(snapshot: snapshot)
                }
            case .rating:
                HStack(spacing: 5) {
                    Group {
                        if let rating = anchorage.rating {
                            SingleStarRating(value: rating)
//                            Text((rating * 5).rounded, format: .number)
                        } else {
                            Text("--")
                        }
                    }
                    .fixedSize()
                    if let snapshot = anchorage.tideAtArrival {
                        Image(systemName: snapshot.movement.symbolName)
                            .frame(width: 5)
                            .font(.caption2)
                    }
                }
                .font(.footnote)
            }
        }
        enum IconType: String, CaseIterable {
            case distance, tide, rating
        }
    }
}

extension String {
    static let anchorageLinkIconTypeKey = "com.saltily.Mewx.anchorageLinkIconTypeKey" // AnchorageLink.IconImage.IconType
}
