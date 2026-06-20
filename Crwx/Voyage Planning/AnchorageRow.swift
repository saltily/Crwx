//
//  AnchorageRow.swift
//  Mewx
//
//  Created by Matthew Goacher on 4/3/25.
//

import SwiftUI
import FoundationSalt
import FoundationUI

struct AnchorageRow: View {
    @Binding var anchorage: AnchoragePotential
    let engine: PotentialAnchorages.Engine
    @State private var isLoading = false
    @State private var task: Task<AnchoragePotential,Error>?
    @Environment(\.modelContext) private var context
    @Environment(\.anchorageSetter) private var anchorageSetter
    var body: some View {
        NavigationLink(destination: AnchorageDetail(anchorage: anchorage).environment(\.anchorageSetter, anchorageSetter)) {
            RowGuts(anchorage: anchorage, isLoading: isLoading)
                .frame(height: 95)
        }
        .banded(anchorage.colour, trailing: 10)
        .onChange(of: anchorage, initial: true) { oldValue, newValue in
            if !newValue.isLoaded {
                reload()
            }
        }
    }
    private func reload() {
        task?.cancel()
        isLoading = true
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
            }
        }
    }
}
fileprivate struct RowGuts: View {
    let anchorage: AnchoragePotential
    let isLoading: Bool
    @Environment(\.modelContext) private var context
    var body: some View {
        let harbour = Harbour.find(anchorage.destination, in: context)
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 15) {
                Text(anchorage.name)
                    .font(.headline)
                if anchorage.darkArrival {
                    Image(systemName: "moon.fill")
                        .font(.subheadline)
                }
                Spacer()
                Group {
                    (Text(anchorage.distance.rounded, format: .number) + Text(" nm"))
                        .font(.footnote)
                    Text(anchorage.duration, format: .duration.separator(.narrow).grouping(.none).hour().minute(2).fractionLength(0))
                        .font(.subheadline)
                    Text(anchorage.eta, format: .dateTime.hour().minute())
                }
//                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .frame(height: 25)
            HStack(spacing: 15) {
                HStack(spacing: 5) {
                    Group {
                        if let harbour {
                            RatingSymbol(harbour.rating, predicted: harbour.guideRating?.percentage)
                        } else {
                            RatingSymbol(0)
                        }
                    }
                    .font(.caption2)
                    .ratingSpacing(1)
                    .foregroundStyle(.yellow)
                    if anchorage.mooringsAvailable {
                        Image(systemName: Facility.mooringsOrSlips.systemImage)
                            .font(.caption2)
                    }
                }
                Spacer()
                Group {
//                    if let minimumUKC = anchorage.minimumUKC {
//                        (Text("UKC ") + Text(minimumUKC, format: .number.precision(.fractionLength(0...1))) + Text(" ft"))
//                            .foregroundStyle(minimumUKC < 0 ? Color.red : (minimumUKC < 1 ? .orange : .secondary))
//                    }
                    Text(anchorage.holdingSummary)
                        .foregroundStyle(anchorage.holdingScore?.nilIfGreen?.colour ?? .secondary)
                }
                .font(.footnote)
                .fixedSize()
                Group {
                    if let windExposure = anchorage.windExposure {
                        HarbourAtAGlance.WindChunk(value: windExposure)
                    }
                    if let swellExposure = anchorage.swellExposure {
                        HarbourAtAGlance.SwellChunk(value: swellExposure)
                    }
                    if isLoading {
                        ProgressView()
                    }
                }
                .font(.subheadline)
            }
            .foregroundStyle(.secondary)

            Text(harbour?.textSample ?? "")
                .lineLimit(1)
                .padding(.top, 5)
                .font(.caption)
        }
        

        // I wanna see the distance and hours
        // I wanna see the tide and arrival ukc
        // I wanna see the overnight ukc, holding, wind, and swell
    }
}
