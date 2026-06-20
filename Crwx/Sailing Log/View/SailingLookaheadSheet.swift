//
//  SailingLookaheadSheet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/15/25.
//

import SwiftUI
import FoundationSalt
import WxSalt
import os

struct SailingLookaheadSheet: View {
    @Bindable var model: SailingLookaheadViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Pinned Location")
                    Spacer()
                    Text("ETA")
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                    Text(model.eta, format: .dateTime.hour().minute())
                        .foregroundStyle(.secondary)
                }
                .font(.title3)
                .fontWeight(.semibold)
                Divider()
                
                
                HStack(spacing: 20) {
                    Text("TTG")
                    Spacer()
                    Text(model.ttg, format: .duration.separator(.narrow).grouping(.none).hour().minute(2).fractionLength(0))
                        .foregroundStyle(.secondary)
                    Text("DTG")
                    Spacer()
                    let s = model.distance.formatted(.number.precision(.fractionLength(1)))
                    Text("\(s) nm")
                        .foregroundStyle(.secondary)
                }
                
                
                Divider()
                HStack(spacing: 20) {
                    Text("Winds")
                    Spacer()
                    if let winds = model.winds {
                        Text(winds.summary)
                            .foregroundStyle(.secondary)
                    } else {
                        ProgressView()
                    }
                    Text("Tide")
                    Spacer()
                    if let tide = model.tide {
                        HStack {
                            Image(systemName: tide.movement.symbolName)
                                .font(.subheadline)
                            let n = tide.height.converted(to: .feet).value
                            let s = n.formatted(.number.precision(.fractionLength(0...1)))
                            Text("\(s) ft")
                        }
                        .foregroundStyle(.secondary)
                    } else {
                        ProgressView()
                    }
                }
            }
            .padding()
        }
        .task {
            do {
                try await model.fetchWx()
            } catch {
                logger.critical("Error fetching tides and wind for lookahead: \(error)")
            }
        }
    }
}
