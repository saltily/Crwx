//
//  VoyageConditionsLine.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/5/25.
//

import SwiftUI
import FoundationSalt
import FoundationUI
import WxSalt

struct VoyageConditionsLine: View {
    let start: UUID
    let etd: Date
    let eta: Date
    let engine: PotentialAnchorages.Engine
    @State private var winds: [WindSnippet] = []
    @State private var floods: [Range<Date>] = []
    @StateObject private var task = PerformTask<([WindSnippet], [Range<Date>])>(multiple: .replacesRunning)
    var body: some View {
        HStack(spacing: 10) {
            if task.isRunning {
                ProgressView()
                    .scaleEffect(0.8)
            }
            Text(windsSummary)
            FloodsBar(period: etd..<eta, floods: floods)
            Text(floodsSummary)
        }
        .frame(height: 12)
        .padding(.bottom, 6)
        .onChange(of: start, initial: true) { oldValue, newValue in
            reload()
        }
        .onChange(of: etd) { oldValue, newValue in
            reload()
        }
        .onChange(of: eta) { oldValue, newValue in
            reload()
        }
        .errorAlert(error: $task.error)
    }
    
    private func reload() {
        task.perform {
            try await engine.loadConditions(underway: etd...eta, start: start)
        } then: { (winds, floods) in
            self.winds = winds
            self.floods = floods
        }
    }
    private var windsSummary: String {
        winds.map {
            $0.summary
        }.orderedSet.joined(separator: ", ")
    }
    private var floodsSummary: String {
        guard !winds.isEmpty || !floods.isEmpty else { return "" }
        let durationFlooding = floods.reduce(0) { partialResult, r in
            partialResult + r.duration
        }
        let durationOverall = eta.timeIntervalSince(etd)
        let floodingPercent = durationFlooding / durationOverall
        if floodingPercent < 0.5 {
            let ebbingPercent = 1 - floodingPercent
            return ebbingPercent.formatted(.percent.precision(.fractionLength(0))) + " ebb"
        }
        return floodingPercent.formatted(.percent.precision(.fractionLength(0))) + " fld"
    }
}


fileprivate struct FloodsBar: View {
    let period: Range<Date>
    let floods: [Range<Date>]
    private let barThickness: CGFloat = 6
    var body: some View {
        GeometryReader { geometry in
            let widthPerSecond = geometry.size.width / period.duration
            ZStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .opacity(0.3)
                    ForEach(floods, id: \.self) { r in
                        Rectangle()
                            .fill(.white.opacity(0.7))
                            .frame(width: r.duration * widthPerSecond)
                            .offset(x: r.lowerBound.timeIntervalSince(period.lowerBound) * widthPerSecond)
                    }
                    .clipShape(Capsule())
                }
                .frame(height: barThickness)
                .overlay(alignment: .leading) {
                    ForEach(timesToDisplay, id: \.self) { t in
                        Text(t, format: .dateTime.hour().minute())
                            .offset(x: t.timeIntervalSince(period.lowerBound) * widthPerSecond, y: 14)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .alignmentGuide(.leading) { d in
                        d[HorizontalAlignment.center]
                    }
                }
            }
        }
        .frame(height: barThickness)
    }
    private var timesToDisplay: [Date] {
        floods.reduce(into: []) { partialResult, range in
            if period.contains(range.lowerBound),
               range.lowerBound.timeIntervalSince(period.lowerBound) > 30.minute
            { partialResult.append(range.lowerBound) }
            if period.contains(range.upperBound),
               period.upperBound.timeIntervalSince(range.upperBound) > 30.minute
            { partialResult.append(range.upperBound) }
        }
    }
}
