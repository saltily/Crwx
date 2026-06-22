//
//  PredepartureFetchDetail.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/12/24.
//

import SwiftUI
import FoundationSalt
import FoundationUI
import CoreLocation
import WxSalt

struct PredepartureFetchDetail: View {
    init(model: Binding<PreDepartureViewModel>) {
        self._model = model
        self._point = .init(initialValue: model.wrappedValue.localForecast?.point?.clLocation ?? .default)
    }
    @Binding var model: PreDepartureViewModel
    @State private var localEditorHasFocus = false
    @State private var marineEditorHasFocus = false
    @State private var buoyEditorHasFocus = false
    @State private var tideEditorHasFocus = false
    
    private var dateWrapped: Binding<Date?> {
        .init {
            model.date
        } set: { newValue in
            if let newValue {
                model.date = newValue
            }
        }
    }
    @State private var point: CLLocation
    @State private var error: Error?
    var body: some View {
        List {
            Group {
                // MARK: Date
                Section {
                    DatePicker("Date", selection: $model.date, displayedComponents: [.date, .hourAndMinute])
                        .padding(.vertical, 5)
                        .swipeActions(edge: .leading) {
                            Button(systemImage: "clock") {
                                model.date = .now
                            }
                            .tint(.accentColor)
                        }
                } header: {
                    HStack {
                        Text("Trip Date")
                        Spacer()
                        Text(model.date, format: .dateTime.weekday(.wide))
                    }
                } footer: {
                    VStack {
                        if let departureTime = model.departureTime {
                            HStack {
                                Text("Departure Time")
                                Spacer()
                                Text(departureTime, format: .dateTime)
                            }
                        }
                        if let arrivalTime = model.trip?.arrivalTime {
                            HStack {
                                Text("Arrival Time")
                                Spacer()
                                Text(arrivalTime, format: .dateTime)
                            }
                        }
                    }
                }
                .onChange(of: model.date) { oldValue, newValue in
                    do {
                        try model.trip?.validate(tripDate: newValue)
                    }
                    catch {
                        model.date = oldValue
                        self.error = error
                    }
                }
                .errorAlert(error: $error)
                
                
                // MARK: Local Weather Section
                LocalWeatherEditor(wx: $model.localForecast, date: $model.date, point: $point, hasFocus: $localEditorHasFocus)
                    .onChange(of: localEditorHasFocus) { oldValue, newValue in
                        if !newValue {
                            marineEditorHasFocus = true
                        }
                    }
                
                
                // MARK: Marine Weather Section
                MarineWeatherEditor(wx: $model.marineForecast, date: $model.date, point: $point, hasFocus: $marineEditorHasFocus)
                    .onChange(of: marineEditorHasFocus) { oldValue, newValue in
                        if !newValue {
                            buoyEditorHasFocus = true
                        }
                    }
                
                
                
                // MARK: Buoy Section
                BuoyObservationEditor(observation: $model.buoyObservation, time: dateWrapped, point: $point, hasFocus: $buoyEditorHasFocus)
                    .onChange(of: buoyEditorHasFocus) { oldValue, newValue in
                        if !newValue {
                            tideEditorHasFocus = true
                        }
                    }
                
                
                
                // MARK: Tide Predictions Section
                TidePredictionsEditor(predictions: $model.tidePredictions, date: $model.date, point: $point, hasFocus: $tideEditorHasFocus)
            }
            .seaSection()
            
        }
        .listStyle(.grouped)
        .seaBackground(.darkSeaGreen)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Manual Override")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

#Preview {
    NavigationStack {
        PredepartureFetchDetail(model: .constant(.preview()))
    }
    .locationManager()
    .preferredColorScheme(.dark)
}
