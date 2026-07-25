//
//  UnderwayFetchDetail.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/11/24.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import CoreLocation
import WxSalt

struct UnderwayFetchDetail: View {
    @Binding var model: UnderwayViewModel
    let landing: UnderwayButton.Landing
    
    private enum FocusedField {
        case locationName, latitude, longitude, heightOfTide, tidalCurrent
    }
    @FocusState private var currentField: FocusedField?
    @PositionTracker private var tracker
    @State private var buoyEditorHasFocus = false
    
    // view models
    @State private var isLoaded = false
    @State private var time: Date = .now
    @State private var locationName: String = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var point: CLLocation = .default
    // tide
    @State private var tideStation: TideStation = .default
    @State private var heightOfTide: Double?
    var body: some View {
        List {
            Group {
                // MARK: Time
                Section {
                    if let _ = model.time {
                        DatePicker("Time", selection: $time, displayedComponents: [.date, .hourAndMinute])
                            .padding(.vertical, 5)
                    }
                    else {
                        Button("Set time") {
                            model.time = time
                        }
                    }
                } header: {
                    Text("\(landing.rawValue.capitalised) Time")
                } footer: {
                    VStack {
                        if let tripTime = model.trip?.date {
                            HStack {
                                Text("Trip Date")
                                Spacer()
                                Text(tripTime, format: .dateTime.weekday().month(.defaultDigits).day().year(.defaultDigits).hour().minute())
                            }
                        }
                        switch landing {
                        case .departure:
                            if let arrivalTime = model.trip?.arrivalTime {
                                HStack {
                                    Text("Arrival Time")
                                    Spacer()
                                    Text(arrivalTime, format: .dateTime)
                                }
                            }
                        case .arrival:
                            if let departureTime = model.trip?.departureTime {
                                HStack {
                                    Text("Departure Time")
                                    Spacer()
                                    Text(departureTime, format: .dateTime)
                                }
                            }
                        }
                    }
                }
                .onChange(of: time) { oldValue, newValue in
                    // can't do this because it will check while the field is in use with the spinner
//                    do {
//                        switch landing {
//                        case .departure:
//                            try model.trip?.validate(departureTime: newValue)
//                        case .arrival:
//                            try model.trip?.validate(arrivalTime: newValue)
//                        }
                        model.time = time
                        refreshTide()
//                    }
//                    catch {
//                        if let t = model.trip?.valid(departureTime: oldValue)
//                        {
//                            time = t
//                            refreshTide()
//                        }
//                        refreshError = error
//                    }
                }
                
                // MARK: Location
                Section("Location") {
                    LabeledContent("Location Name") {
                        TextField("Name", text: $locationName)
                            .multilineTextAlignment(.trailing)
                            .focused($currentField, equals: .locationName)
                            .autocorrectionDisabled()
                    }
                    .onSubmit {
                        updateLocation()
                        currentField = .latitude
                    }
                    .submitLabel(.next)
                    .onDisappear {
                        updateLocation()
                    }
                    CoordinateField(.latitude, value: $latitude)
                        .focused($currentField, equals: .latitude)
                        .onChange(of: latitude) { oldValue, newValue in
                            writeToPoint()
                        }
                        .onSubmit {
                            writeToPoint()
                            currentField = .longitude
                        }
                    CoordinateField(.longitude, value: $longitude)
                        .focused($currentField, equals: .longitude)
                        .onChange(of: longitude) { oldValue, newValue in
                            writeToPoint()
                        }
                        .onSubmit {
                            writeToPoint()
                            currentField = .heightOfTide
                        }
                    LocationPointPicker(point: $point) { name in
                        if locationName.isEmpty {
                            locationName = name
                        }
                    }
                    Button {
                        fetchCurrentLocation()
                    } label: {
                        Label("Fetch current location", systemImage: "mappin.circle")
                    }
                }
                .onChange(of: point) { oldValue, newValue in
                    updatePoint()
                }
                
                
                // MARK: Tide
                Section("Tide") {
                    LocationTideStationPicker(station: $tideStation)
                        .swipeActions(edge: .leading) {
                            Button(systemImage: "mappin.circle") {
                                if let nearest = TideStation.all.nearest(to: point) {
                                    tideStation = nearest.value
                                }
                            }
                            .tint(.accentColor)
                        }
                    LabeledContent("Height of Tide") {
                        HStack {
                            TextField("Tide", value: $heightOfTide, format: .number.precision(.fractionLength(0...1)))
                                .multilineTextAlignment(.trailing)
                                .focused($currentField, equals: .heightOfTide)
                                .onSubmit {
                                    updateTide()
                                    currentField = .tidalCurrent
                                }
                                .submitLabel(.next)
                                .keyboardType(.decimalPad)
                            Text("ft")
                        }
                    }
                    LabeledContent("Tidal Current") {
                        TextField(model.predictedTidalCurrent.nilIfEmpty ?? "Current", text: $model.tidalCurrent)
                            .textInputAutocapitalization(.never)
                            .multilineTextAlignment(.trailing)
                            .focused($currentField, equals: .tidalCurrent)
                            .onSubmit {
                                buoyEditorHasFocus = true
                            }
                            .submitLabel(.next)
                    }
                    if let snapshot = model.tide {
                        LabeledContent("Movement of Tide", value: snapshot.movement.rawValue)
                        LabeledContent("Percent In", value: snapshot.percentIn, format: .percent.precision(.fractionLength(0)))
                        LabeledContent("Next Tide") {
                            HStack {
                                Text(snapshot.nextTide?.date.timeIntervalSince(snapshot.date) ?? 0, format: .duration.driving)
                                    .padding(.trailing, 8)
                                Text(snapshot.nextTide?.isHi == true ? "H" : "L")
                                Text(snapshot.nextTide?.height ?? 0, format: .number.precision(.fractionLength(0...1))) + Text(" ft")
                            }
                        }
                    }
                    if refreshingTide {
                        ProgressView()
                    }
                    else {
                        Button {
                            refreshTide(silently: false)
                        } label: {
                            Label("Refresh tide", systemImage: "arrow.clockwise.circle")
                        }
                    }
                }
                .errorAlert(error: $refreshError)
                .onChange(of: tideStation) { oldValue, newValue in
                    refreshTide()
                }
                
                
                // MARK: Buoy Observation
                BuoyObservationEditor(observation: $model.observation, time: $model.time, point: $point, hasFocus: $buoyEditorHasFocus)
            }
            .seaSection()
        }
        .listStyle(.grouped)
        .seaBackground(.flat)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Manual Override")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadViewModels()
        }
    }
    
    
    private func loadViewModels() {
        if !isLoaded {
            time = model.time ?? .now
            locationName = model.location?.name ?? ""
            latitude = model.location?.latitude
            longitude = model.location?.longitude
            point = model.location?.clLocation ?? .default
            tideStation = model.tide?.station?.resolved ?? .default
            heightOfTide = model.tide?.height
            isLoaded = true
        }
    }
    
    // MARK: Refresh tide
    @State private var refreshingTide = false
    @State private var refreshError: Error?
    private func refreshTide(silently: Bool = true) {
        let service = TideWxService()
        if !silently {
            refreshingTide = true
        }
        Task {
            do {
                guard let date = model.time
                else { throw "Could not find tide data for this time" }
                let tides = try await service.weather(for: tideStation, from: date.addingTimeInterval(-2.day), to: date.addingTimeInterval(2.day))
                guard let snapshot = tides.look(at: date)?.snippet(station: tideStation.snippet)
                else { throw "Could not find tide data for this time" }
                await MainActor.run {
                    model.tide = snapshot
                    model.predictedTidalCurrent = snapshot.predictedCurrent
                    heightOfTide = snapshot.height
                    refreshingTide = false
                }
            }
            catch {
                await MainActor.run {
                    if !silently {
                        refreshError = error
                    }
                    refreshingTide = false
                }
            }
        }
    }
    func updateTide() {
        if var tide = model.tide {
            tide.date = time
            tide.station = tideStation.snippet
            tide.height = heightOfTide ?? tide.height
            model.tide = tide
        }
        else if let heightOfTide {
            model.tide = .init(date: time, height: heightOfTide, movement: .standingHi, percentIn: 0.5, nextTide: .init(date: time, height: heightOfTide, isHi: true, station: tideStation.snippet), station: tideStation.snippet)
        }
    }
    
    
    
    // MARK: Refresh Location
    private func fetchCurrentLocation() {
        Task {
            if let current = await tracker.currentLocation { // ?? .randomOnCoastOfMaine()
                point = current
            }
        }
    }
    private func writeToPoint() {
        if let latitude,
           let longitude
        {
            point = .init(latitude: latitude, longitude: longitude)
        }
    }
    private func updatePoint() {
        if let oldPoint = model.location,
           oldPoint.distance(to: point).converted(to: .nauticalMiles).value > 0.25
        {
            locationName = ""
        }
        self.latitude = point.coordinate.latitude
        self.longitude = point.coordinate.longitude
        updateLocation()
    }
    private func updateLocation() {
        if let latitude,
           let longitude
        {
            model.location = .init(name: locationName, latitude: latitude, longitude: longitude)
        }
    }
}

#Preview {
    NavigationStack {
        UnderwayFetchDetail(model: .constant(.preview()), landing: .arrival)
    }
    .locationManager()
}
