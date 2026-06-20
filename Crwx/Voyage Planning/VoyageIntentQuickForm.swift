//
//  VoyageIntentQuickForm.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/29/25.
//

import SwiftUI

struct VoyageIntentQuickForm: View {
    @Binding var intent: VoyageIntent
    @AppStorage(.voyageIntentQuickFieldKey) private var field: Field = .speed
    @AppStorage(.anchorageLinkIconTypeKey) private var iconType: AnchorageLink.IconImage.IconType = .distance
    var body: some View {
        HStack {
            Picker("Field", selection: $field) {
                Text("Day").tag(Field.day)
                Text("Depart").tag(Field.from)
                Text("Arrive by").tag(Field.to)
                Text("Speed").tag(Field.speed)
                Text("Icon").tag(Field.icon)
            }
            SunHint(field: field, sunrise: intent.sunrise, sunset: intent.sunset)
                .foregroundStyle(.secondary)
                .font(.caption)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
            switch field {
            case .day:
                Stepper("Day") {
                    intent.tomorrow()
                } onDecrement: {
                    intent.yesterday()
                }
            case .from:
                Stepper("From", value: $intent.departureHour, step: .Hour)
            case .to:
                Stepper("To", value: $intent.arrivalHour, step: .Hour)
            case .speed:
                Stepper("Speed", value: $intent.estimatedSpeed, step: 0.1)
            case .icon:
                Picker("Icon", selection: $iconType) {
                    ForEach(AnchorageLink.IconImage.IconType.allCases, id: \.rawValue) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .labelsHidden()
            }
        }
        .labelsHidden()
    }
    private var value: String {
        switch field {
        case .day:
            intent.preferredArrival.isToday ? "today" :
            (intent.preferredArrival.isYesterday ? "yesterday" :
            intent.preferredArrival.formatted(.relative(presentation: .named)))
        case .from:
            intent.estimatedDeparture.formatted(.dateTime.hour().minute())
        case .to:
            intent.preferredArrival.formatted(.dateTime.hour().minute())
        case .speed:
            intent.estimatedSpeed.formatted(.number.precision(.fractionLength(0...1))) + " kts"
        case .icon:
            ""
        }
    }
    enum Field: String, Codable {
        case day, from, to, speed, icon
    }
}

fileprivate struct SunHint: View {
    let field: VoyageIntentQuickForm.Field
    let sunrise: Date
    let sunset: Date
    var body: some View {
        HStack {
            switch field {
            case .day, .speed, .icon:
                EmptyView()
            case .from:
                Image(systemName: "sunrise")
                Text(sunrise, format: .dateTime.hour().minute())
            case .to:
                Image(systemName: "sunset")
                Text(sunset, format: .dateTime.hour().minute())
            }
        }
    }
}
