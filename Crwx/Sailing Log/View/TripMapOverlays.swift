//
//  TripMapOverlays.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/8/25.
//

import SwiftUI
import FoundationUI
import WxSalt
import FoundationSalt

struct TripMapOverlays: View {
    @Bindable var trip: Trip
    var body: some View {
        
        // MARK: top left conditions
        TripMapSection(corner: .topLeading) {
            Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 8) {
                if let winds = trip.marineForecast?.winds ?? trip.localForecast?.winds {
                    GridRow {
                        WindDirectionSymbol(directions: .init(directions: winds.angles))
                            .gridColumnAlignment(.center)
                        Text(winds.summaryWithGusts)
                    }
//                    ForEach(0..<winds.count, id: \.self) { i in
//                        let wind = winds[i]
//                        GridRow {
//                            WindDirectionSymbol(directions: .init(wind.angle))
//                                .gridColumnAlignment(.center)
//                            Text(wind.speedSummaryWithGusts)
//                        }
//                    }
                }
                if let marineForecast = trip.marineForecast,
                   marineForecast.lowWaveFeet != nil
                {
                    GridRow {
                        Text(" ")
                        Text(marineForecast.wavesSummary)
                    }
                }
                GridRow {
                    TowingSymbol(dinghy: trip.dinghy)
                        .gridColumnAlignment(.center)
                    if let percentFlooding = trip.percentFlooding?.rounded(0.01) {
                        if percentFlooding < 0.5 {
                            let s = (1 - percentFlooding).formatted(.percent)
                            Text("\(s) ebb")
                        } else {
                            let s = percentFlooding.formatted(.percent)
                            Text("\(s) fld")
                        }
                    }
                }
            }
        }
        
        // MARK: bottom left speeds
        TripMapSection(corner: .bottomLeading) {
            Grid(alignment: .trailing, horizontalSpacing: 5, verticalSpacing: 8) {
                GridRow {
                    Text("SOG:")
                        .monospaced()
                    DoubleText(value: trip.averageSpeed)
                    Text("kts avg")
                        .gridColumnAlignment(.leading)
                }
                GridRow {
                    Text(" ")
                    DoubleText(value: trip.maximumSpeed)
                    Text("kts max")
                }
            }
        }
        let leg = trip.overallLeg
        
        // MARK: bottom right consumption
        TripMapSection(corner: .bottomTrailing) {
            Grid(alignment: .trailing, horizontalSpacing: 5, verticalSpacing: 8) {
                if let leg, !leg.isZero,
                   let duration = trip.duration
                {
                    let speedMadeGood = (trip.route?.distance ?? leg.nauticalMiles) / (duration / .Hour)
                    GridRow {
                        Text("SMG:")
                            .monospaced()
                        DoubleText(value: speedMadeGood)
                        Text("kts")
                            .gridColumnAlignment(.leading)
                    }
                }
                GridRow {
                    Text("CSM:")
                        .monospaced()
                    DoubleText(value: trip.gallonsConsumed)
                    Text("gals")
                        .gridColumnAlignment(.leading)
                }
            }
        }
        
        // MARK: top right effort
        TripMapSection(corner: .topTrailing) {
            Grid(alignment: .trailing, horizontalSpacing: 5, verticalSpacing: 8) {
                if let leg,
                   !leg.isZero
                {
                    GridRow {
                        Group {
                            if let cmg = trip.cmg {
                                Image(systemName: "location.north.line.fill")
                                    .rotationEffect(.degrees(cmg.degrees))
                            } else {
                                Image(systemName: "arrow.trianglehead.clockwise")
                            }
                        }
                        .padding(.trailing, 5)
                        .gridColumnAlignment(.center)
                        DoubleText(value: trip.route?.distance ?? leg.nauticalMiles)
                        Text("nm")
                            .gridColumnAlignment(.leading)
                    }
                }
                GridRow {
                    Text("MMG:")
                        .monospaced()
                    DoubleText(value: trip.milesMadeGood)
                    Text("nm")
                        .gridColumnAlignment(.leading)
                }
                GridRow {
                    Text("DUR:")
                        .monospaced()
                    PlaceholderText(trip.duration?.formatted(.duration.separator(.narrow).hour().minute(2).fractionLength(0).grouping(.none)) ?? "", placeholder: "--")
                        .gridCellColumns(2)
                }
            }
        }
    }
}
