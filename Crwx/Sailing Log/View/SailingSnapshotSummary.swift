//
//  SailingSnapshotRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/13/25.
//

import SwiftUI
import FoundationSalt

struct SailingSnapshotSummary: View {
    @Bindable var model: SailingSnapshotViewModel
    var body: some View {
        // button drill for more details (but wrap this view so this can be reused on details)
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: ETA
            HStack {
                if let eta = model.eta {
                    Text(eta, format: .dateTime.hour().minute())
                        .foregroundStyle(.secondary)
                } else {
                    Text("10:00")
                        .redacted(reason: .placeholder)
                }
                    
                Text("ETA")
                    .foregroundStyle(.secondary)
                    .font(.headline)
                    .fontWeight(.regular)
                Spacer()
                Image(systemName: "sailboat.circle")
                    .foregroundStyle(.secondary)
                    .font(.body)
                    .fontWeight(.regular)
                Text(model.destinationName)
            }
            .font(.title3)
            .fontWeight(.semibold)
            Divider()

            // MARK: DTG
            HStack(spacing: 20) {
                Text("TTG")
                Spacer()
                if let ttg = model.ttg {
                    Text(ttg, format: .duration.separator(.narrow).grouping(.none).hour().minute(2).fractionLength(0))
                        .foregroundStyle(.secondary)
                } else {
                    Text("3h00")
                        .redacted(reason: .placeholder)
                }
                Text("DTG")
                Spacer()
                (Text(model.dtg, format: .number.precision(.fractionLength(1))) + Text(" nm"))
                    .foregroundStyle(.secondary)
            }
            
            // MARK: MMG
            HStack(spacing: 20) {
                Text("SMG")
                Spacer()
                if let smg = model.smg {
                    (Text(smg, format: .number.precision(.fractionLength(1))) + Text(" kts"))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                } else {
                    Text("3.0 kts")
                        .redacted(reason: .placeholder)
                }
                Text("MMG")
                Spacer()
                (Text(model.mmg, format: .number.precision(.fractionLength(1))) + Text(" nm"))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            // MARK: Current Speed
            HStack(spacing: 20) {
                Text("SPD")
                Spacer()
                if let spd = model.spd {
                    (Text(spd, format: .number.precision(.fractionLength(1))) + Text(" kts"))
                        .foregroundStyle(.secondary)
                } else {
                    Text("3.0 kts")
                        .redacted(reason: .placeholder)
                }
                Text("HDG")
                Spacer()
                if let hdg = model.hdg {
                    (Text(hdg.cardinalDirection.abbreviation) + Text(" ") +
                    Text(hdg.converted(to: .degrees).value, format: .number.precision(.integerAndFractionLength(integer: 3, fraction: 0))) +
                    Text("ºT"))
                    .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 1) {
                        Text("N 004")
                            .redacted(reason: .placeholder)
                        Text("ºT")
                    }
                }
            }
            
            Divider()
            HStack {
                (Text("Departed ") +
                Text(model.timeUnderway, format: .duration.separator(.narrow).grouping(.none).hour().minute(2).fractionLength(0)) +
                Text(" ago. Current time is ") +
                Text(model.currentTime, format: .dateTime.hour().minute()) +
                Text("."))
                Spacer()
                CurrentTideView(time: model.currentTime, location: model.currentLocation)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

        }
    }
}
//
//#Preview {
//    List {
//        SailingSnapshotSummary()
//            .seaSection()
//    }
//    .seaBackground()
//}
