//
//  SoundingValueRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import FoundationUI

struct SoundingValueRow: View {
    @Bindable var value: Sounding
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading) {
                    Text(value.date, format: .dateTime.month().day().year().hour().minute())
                    Text(value.date, format: .relative(presentation: .named))
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    if value.type == .water {
                        PlaceholderText(value.waterValue?.gallons ?? "")
                    } else {
                        HStack(spacing: 5) {
                            PlaceholderText(value.value, format: .number.precision(.fractionLength(0...1)))
                            Text(value.type.units)
                        }
                    }
                    Group {
                        switch value.type {
                        case .water:
                            PlaceholderText(value.waterValue?.percent ?? "")
                        case .fuel:
                            HStack(spacing: 5) {
                                PlaceholderText(value.fuelSounding?.inches?.eighths ?? "")
                                Text("in")
                            }
                        default:
                            EmptyView()
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            if let notes = value.note.nilIfEmpty {
                Text(notes)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .editSounding(value)
        .deleteSounding(value)
    }
}

