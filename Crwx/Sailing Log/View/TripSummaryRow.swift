//
//  TripSummaryRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI

struct TripSummaryRow: View {
    @Bindable var trip: Trip
    @State private var confirmDelete = false
    @Environment(\.modelContext) private var context
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Group {
                    if trip.date.isToday {
                        Text("Today")
                    }
                    else if trip.date.isYesterday {
                        Text("Yesterday")
                    }
                    else if Date.now.timeIntervalSince(trip.date) < 5.day {
                        Text(trip.date, format: .dateTime.weekday(.wide))
                    }
                    else {
                        Text(trip.date, format: .dateTime.weekday(.wide).month(.wide).day().year())
                    }
                }
                .font(.headline)
                if trip.webId != nil {
                    Image(systemName: "square.and.arrow.up")
                        .opacity(0.3)
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
                Spacer()
                if trip.track != nil {
                    Image(systemName: "scribble")
                        .foregroundStyle(.secondary)
                }
                if (!trip.isCompleted) {
                    Image(systemName: "cellularbars", variableValue: trip.percentComplete)
                }
            }
            Divider()
                .padding(.vertical, 3)
            HStack(spacing: 3) {
                if let start = trip.fromLocation?.name {
                    Text(start)
                    Text("to")
                    if let end = trip.toLocation?.name {
                        Text(end)
                    }
                    else {
                        Text("…")
                    }
                }
                Spacer()
                if let mmg = trip.milesMadeGood {
                    Text(mmg, format: .number.precision(.fractionLength(0...1))) + Text(" mi,")
                }
                if let duration = trip.duration {
                    Text(duration / .Hour, format: .number.precision(.fractionLength(0...1))) + Text(" hrs")
                }
            }
            .font(.caption)
            HStack(spacing: 3) {
                ForecastConditionsSymbol(forecast: trip.localForecast)
                    .padding(.trailing, 7)
                WindsText(winds: trip.marineForecast?.winds ?? trip.localForecast?.winds)
                Spacer()
                DoubleText(value: trip.averageSpeed, suffix: "kts avg")
            }
            .font(.caption)
            HStack(spacing: 3) {
                if !trip.passengers.isEmpty {
                    (Text("+ ") +
                    Text(trip.passengers))
                        .font(.caption)
                }
                Spacer()
                if let fuel = trip.fuelEnd?.gallons {
                    Text("Fuel: ") +
                    Text(fuel, format: .number.precision(.fractionLength(0...1))) + Text(" gals")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.bottom, 3)
        }
        .swipeDeleteWithConfirmation("Confirm Delete") {
            trip.removeFromCruise()
            context.delete(trip)
            try context.save()
        } message: {
            Text("\nAre you sure you would like to delete the trip on\n \(trip.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())) \nfrom \(trip.fromLocation?.name ?? "somewhere") to \(trip.toLocation?.name ?? "somewhere")?\n\nThis action cannot be undone.")
        }
    }
}

#Preview("Complete") {
    let container = previewContainer
    let trip = Trip.preview()
    container.mainContext.insert(trip)
    return List {
        TripSummaryRow(trip: trip)
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}

#Preview("Incomplete") {
    let container = previewContainer
    let trip = Trip.preview(incompletion: 3)
    container.mainContext.insert(trip)
    return NavigationStack {
        List {
            NavigationLink(destination: TripEditor(trip: trip)) {
                TripSummaryRow(trip: trip)
            }
        }
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
    .locationManager()
}
