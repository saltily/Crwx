//
//  VoyageIntentForm.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/27/25.
//

import SwiftUI
import FoundationUI

struct VoyageIntentForm: View {
    @Binding var intent: VoyageIntent
    @Environment(\.modelContext) private var context
    var body: some View {
        List {
            Group {
                // harbour picker
                Section {
                    HarbourPicker("From", value: $intent.start)
                        .onChange(of: intent.start) { oldValue, newValue in
                            if let harbour = Harbour.find(newValue, in: context) {
                                intent.coordinate = harbour.coordinate
                                intent.startName = harbour.name
                            } else {
                                logger.critical("Couldn't find selected harbour - how is that possible?")
                                assertionFailure()
                            }
                        }
                    QuadrantPicker("To the", value: $intent.directionOfTravel)
                }
                Section {
                    HStack {
                        RelativeDayText(intent.preferredArrival.day)
                            .foregroundStyle(.secondary)
                        Stepper("Day") {
                            intent.tomorrow()
                        } onDecrement: {
                            intent.yesterday()
                        }
                        .labelsHidden()
                    }
                    .labeled("Day")
                    DatePicker("Depart", selection: $intent.estimatedDeparture, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Arrive by", selection: $intent.preferredArrival, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Stay until", selection: $intent.stayUntil, displayedComponents: [.date, .hourAndMinute])
                } footer: {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(intent.timeSummary)
                                .foregroundStyle(intent.timesAreValid ? Color.secondary : .orange)
                            HStack {
                                Image(systemName: "sunrise")
                                Text(intent.sunrise, format: .dateTime.hour().minute())
                                Image(systemName: "sunset")
                                Text(intent.sunset, format: .dateTime.hour().minute())
                            }
                        }
                    }
                }
                Section {
                    Stepper(value: $intent.estimatedSpeed, step: 0.1) {
                        HStack {
                            Text("Speed")
                            Spacer()
                            Group {
                                TextField("0.0", value: $intent.estimatedSpeed, format: .number.precision(.fractionLength(0...1)))
                                    .multilineTextAlignment(.trailing)
                                    .keyboardType(.decimalPad)
                                Text("kts")
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                } footer: {
                    HStack {
                        Spacer()
                        Text(intent.range, format: .number.precision(.fractionLength(0...1))) + Text(" nm range")
                    }
                }
            }
            .seaSection()
        }
    }
}

struct EditVoyageIntentButton: View {
    @Binding var intent: VoyageIntent
    @State private var isPresented = false
    var body: some View {
        Button(systemImage: "gearshape") {
            isPresented = true
        }
//        .symbolVariant(.fill)
//        .tint(.primary)
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                VoyageIntentForm(intent: $intent)
                    .saveButton("Done")
                    .seaBackground(.darkSeaBlue)
            }
        }
    }
}
