//
//  AnchorageDetail.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/29/25.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import WxSalt
import SwiftData

struct AnchorageDetail: View {
    let anchorage: AnchoragePotential
    @Environment(\.modelContext) private var context
    @State private var goToMap = false
    @Environment(\.anchorageSetter) private var anchorageSetter
    var body: some View {
        List {
            Group {
                // MARK: Score
                ZeroHeaderSection {
                    
                    // Map Link
                    AnchorageBanner(anchorage: anchorage)
                        .frame(height: 200)
                        .listRowInsets(.init())
                        .onTapGesture {
                            goToMap = true
                        }
                    
                    // Route name and duration, distance
                    HStack {
                        Text("\(anchorage.start.label ?? "?") to \(anchorage.name)")
                        Spacer()
                        Group {
                            Text(anchorage.duration, format: .duration.driving)
                                .font(.footnote)
                            let s = anchorage.distance.formatted(.number.precision(.fractionLength(0...1)))
                            Text("\(s) nm")
                        }
                        .foregroundStyle(.secondary)
                    }
                    .banded(anchorage.colour)
                    
                    // Arrival tide, UKC (coloured), and eta
                    HStack(spacing: 15) {
                        Text("Arrival")
                        Spacer()
                        Group {
                            if let tideAtArrival = anchorage.tideAtArrival {
                                TideMapIcon(snapshot: tideAtArrival)
                            }
                            if let ukcAtArrival = anchorage.ukcAtArrival {
                                let s = ukcAtArrival.formatted(.number.precision(.fractionLength(0...1)))
                                Text("UKC \(s) ft")
                                    .font(.footnote)
                                    .foregroundStyle(ukcAtArrival < 1 ? Color.orange : .secondary)
                            }
                            HStack(spacing: 5) {
                                if anchorage.darkArrival {
                                    Image(systemName: "moon.fill")
                                        .font(.caption2)
                                }
                                Text(anchorage.eta, format: .dateTime.hour().minute())
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                    .banded(anchorage.colour)
                    
                    // Overnight UKC (coloured), holding (coloured), wind (coloured), and swell (coloured)
                    HStack(spacing: 10) {
                        Text("Overnight")
                            .fixedSize()
                        Spacer()
                        Group {
                            Group {
                                if let minimumUKC = anchorage.minimumUKC {
                                    let s = minimumUKC.formatted(.number.precision(.fractionLength(0...1)))
                                    Text("UKC \(s) ft")
                                        .foregroundStyle(minimumUKC < 0 ? Color.red : (minimumUKC < 1 ? .orange : .secondary))
                                }
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
                            }
                            .font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                    }
                    .banded(anchorage.colour)
                } footer: {
                    HStack {
                        Spacer()
                        let s1 = anchorage.eta.formatted(.dateTime.weekday(.wide).hour().minute())
                        let s2 = anchorage.etd.formatted(.dateTime.weekday(.wide).hour().minute())
                        let s3 = (anchorage.etd.timeIntervalSince(anchorage.eta) / .Hour).rounded.appending("hour", "hours")
                        Text("\(s1) to \(s2), \(s3)")
                    }
                }
                
                // MARK: Harbour
                if let harbour = Harbour.find(anchorage.destination, in: context) {
                    Section("Harbour") {
                        NavigationLink(destination: HarbourDetail(harbour: harbour)) {
                            HarbourAtAGlance(harbour: harbour, trimNotes: false)
                        }
//                            .swipeEdit(harbour: harbour)
                        if let notes = harbour.notes.nilIfEmpty,
                           notes != harbour.textSample
                        {
                            Text(notes)
                                .font(.footnote)
                        }
                        if !harbour.cruisingGuide.summary.isEmpty {
                            HarbourGuide(harbour: harbour)
                        }
                    }
                }

                // MARK: Weather
                Section("Forecast") {
                    ForEach(anchorage.forecast, id: \.date) { wx in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(wx.date.half.weekday)
                                .font(.headline)
                            Text(wx.text)
                                .font(.footnote)
                            Text(wx.winds.summaryWithGusts)
                                .labeled("Winds")
                            HStack(alignment: .firstTextBaseline) {
                                Text("Seas")
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(wx.wavesSummary)
                                    if !wx.waves.isEmpty {
                                        Text(wx.waves.summary)
                                    }
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                // MARK: Tide
                if !anchorage.tides.isEmpty {
                    let days = anchorage.eta.withoutTime...anchorage.etd.day.end
                    Section("Tides") {
                        VStack(alignment: .leading) {
                            AnchorageTideChart(plots: anchorage.tides, days: days, tideAtArrival: anchorage.tideAtArrival)
                                .frame(height: 125)
                            if let tideStation = anchorage.tideStation {
                                HStack {
                                    Text("\(tideStation.name), ")
                                    Spacer()
                                    Text(tideStation.relativeSentence(from: anchorage))
                                }
                                .foregroundStyle(.secondary)
                                .font(.caption)
                            }
                        }
                        if let tideAtArrival = anchorage.tideAtArrival {
                            HStack {
                                Text("Tide at Arrival")
                                Spacer()
                                Group {
                                    let n = tideAtArrival.height.converted(to: .feet).value
                                    let s = n.formatted(.number.precision(.fractionLength(1)))
                                    Text("\(s) ft")
                                    Image(systemName: tideAtArrival.movement.symbolName)
                                    Text(anchorage.eta, format: .dateTime.hour().minute())
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                        AnchorageTidePredictions(predictions: anchorage.tides, days: days)
                    }
                }
            }
            .seaSection()
        }
        .zeroListHeader()
        .seaBackground()
        .navigationTitle(anchorage.name)
        .navigationDestination(isPresented: $goToMap) {
            AnchoragePanner(anchorage: anchorage)
        }
        .toolbar {
            if let anchorageSetter {
                ToolbarItem {
                    DismissButton("Select") {
                        anchorageSetter.save(anchorage)
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
fileprivate struct HarbourGuide: View {
    @Bindable var harbour: Harbour
    var body: some View {
        NavigationLink(destination: CruisingGuideReader(harbour.name, cruisingGuide: $harbour.cruisingGuide)) {
            Text(harbour.cruisingGuide.summary)
                .lineLimit(1...3)
                .font(.footnote)
        }
    }
}
