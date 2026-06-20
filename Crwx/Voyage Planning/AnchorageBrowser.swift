//
//  AnchorageBrowser.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/29/25.
//

import SwiftUI
import FoundationSalt
import FoundationUI

struct AnchorageBrowser: View {
    let tab: Int
    @Binding var intent: VoyageIntent
    @Bindable var destinations: HarbourDestinations
    @Bindable var anchorages: PotentialAnchorages
    var body: some View {
        Group {
            if tab == 1 {
                PotentialAnchoragesMap(intent: intent, anchorages: anchorages)
            } else if tab == 2 {
                PotentialAnchoragesList(intent: intent, anchorages: anchorages)
            }
        }
        .onChange(of: intent, initial: true) { oldValue, newValue in
            reload()
        }
        .onChange(of: destinations.viewModels) { oldValue, newValue in
            reload()
        }
        .safeAreaInset(edge: .top) {
            VStack {
                Group {
                    RelativeNightText(intent.preferredArrival.day)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                        .padding(.bottom, 10)
                    Group {
                        HStack {
                            Text(intent.summary)
                            Spacer()
                            Text(intent.timeRange)
                        }
                        VoyageConditionsLine(start: intent.start, etd: intent.estimatedDeparture, eta: intent.preferredArrival, engine: anchorages.engine)
                    }
                    .font(.caption)
                }
                .padding(.horizontal)
                VoyageIntentQuickForm(intent: $intent)
                    .padding(5)
                    .padding(.trailing, 10)
            }
            .padding(.vertical)
            .background(.thinMaterial)
        }
        .toolbar {
            ToolbarItem {
                EditVoyageIntentButton(intent: $intent)
            }
        }
    }
    private func reload() {
        anchorages.loadAnchorages(intent: intent, destinations: destinations.viewModels)
    }
}

fileprivate struct RelativeNightText: View {
    init(_ day: Day) {
        self.day = day
    }
    private let day: Day
    var body: some View {
        if day.isToday {
            Text("Tonight")
        } else if day.isTomorrow {
            Text("Tomorrow")
        } else if day.isYesterday {
            Text("Last Night")
        } else {
            HStack {
                Text(day.start, format: .dateTime.weekday(.wide))
                RelativeDateText(day.start, interval: 5.minute)
                    .foregroundStyle(.secondary)
                    .font(.body)
            }
        }
    }
}
