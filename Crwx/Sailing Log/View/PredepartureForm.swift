//
//  PredepartureForm.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import WxSalt
import SwiftData

struct PredepartureForm: View {
    @State var model: PreDepartureViewModel
    @State private var locationName: String = ""
    var isNew: Bool = false
    @FocusState private var currentField: FocusedField?
    private enum FocusedField {
        case passengers, odometer, locationName
    }
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationStack {
            List {
                Group {
                    Section("Required") {
                        TextField("Passengers", text: $model.passengers)
                            .autocorrectionDisabled()
                            .focused($currentField, equals: .passengers)
                            .onSubmit {
                                currentField = .odometer
                            }
                            .submitLabel(.next)
                        Picker("Dinghy", selection: $model.dinghy) {
                            ForEach(DinghyOption.allCases) { o in
                                Text(o.rawValue.capitalized).tag(o)
                            }
                        }
                    }
                    Section("Confirm") {
                        HStack {
                            Text("Odometer")
                            TextField("Odometer", value: $model.odometer, format: .number.grouping(.never))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .focused($currentField, equals: .odometer)
                                .onSubmit {
                                    currentField = .locationName
                                }
                                .submitLabel(.next)
                            Text("nm")
                        }
                        FuelEditorRow(model: $model.fuel)
                        if let _ = model.localForecast?.point {
                            HStack {
                                Text("Location")
                                TextField("name", text: $locationName)
                                    .multilineTextAlignment(.trailing)
                                    .focused($currentField, equals: .locationName)
                            }
                        }
                        if let anchorageName = model.anchorage?.name {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("My Notes for \(anchorageName) Anchorage")
                                    .fontWeight(.medium)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                TextField("Highlights", text: $model.anchorageHighlights, axis: .vertical)
                                    .font(.subheadline)
                                    .lineLimit(1...3)
                                TextField("Notes", text: $model.anchorageNotes, axis: .vertical)
                                    .font(.subheadline)
                                    .lineLimit(1...)
                            }
                        }
                    }
                    PredepartureFetchRow(model: $model)
                }
                .seaSection()
            }
            .listStyle(.grouped)
            .seaBackground(.flat)
            .navigationTitle(isNew ? "New Trip" : "Pre Departure")
            .toolbarTitleDisplayMode(.inline)
            .cancelButton()
            .saveButton(isNew ? "Start" : "Save") {
                model.fuel?.save(for: model.date, in: context)
                // don't commit weather that is too late after departure
                // buoy has a date, marine and local forecasts have dates
                // tide is already matched to this day
                model.trip?.update(predeparture: model)
                // now is the time to insert new trip
                // but be sure to let the sheet dismiss first, so complete this run loop [AT LEAST THAT'S HOW IT WORKED BEFORE I USED THIS ASYNC SAVE BUTTON]
                model.trip?.track?.date = model.date
                if isNew,
                   let trip = model.trip
                {
                    context.insert(trip)
                    if let anchorage = model.anchorage,
                       trip.startHarbour == nil
                    {
                        trip.startHarbour = anchorage
                        linkToCruise(from: anchorage, on: trip)
                    }
                }
                try context.save()
            }
        }
        .onChange(of: model.localForecast?.point?.name, initial: true) { oldValue, newValue in
            locationName = newValue ?? ""
        }
        .onChange(of: locationName) { oldValue, newValue in
            if let _ = model.localForecast?.point {
                model.localForecast?.point?.name = newValue
            }
        }
    }
    private func linkToCruise(from startHarbour: Harbour, on trip: Trip) {
        // 1. Get the last cruise
        if let cruise = Cruise.last(in: context) {
            // 2. Get the first incomplete leg
            for (i, var leg) in cruise.legs.enumerated() {
                if leg.trip_id == nil {
                    // 3. Does this leg start where we started?
                    if cruise.anchorages[i].harbourId == startHarbour.id,
                       let endHarbour = Harbour.find(cruise.anchorages[i+1].harbourId, in: context)
                    {
                        // 4. Is the day right?
                        let legDay = cruise.start.adding(days: i)
                        let tripDay = trip.date.day
                        if i == 0 || legDay == tripDay {
                            trip.arrivalLocation = .init(endHarbour)
                            trip.endHarbour = endHarbour
                            trip.route = leg.route
                            trip.cruise = cruise
                            cruise.add(child: trip, to: \.trips)
                            leg.trip_id = trip.id
                            leg.winds = trip.marineForecast?.winds ?? leg.winds
                            cruise.legs[i] = leg
                            if i == 0 {
                                cruise.start = tripDay
                            }
                        }
                    }
                    return
                }
            }
        }
    }
}

#Preview {
    List {
        
    }
    .sheet(isPresented: .constant(true)) {
        PredepartureForm(model: .preview())
    }
    .locationManager()
    .preferredColorScheme(.dark)
}
