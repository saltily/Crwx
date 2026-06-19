//
//  BuoyObservationEditor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/12/24.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import CoreLocation
import WxSalt

struct BuoyObservationEditor: View {
    init(observation: Binding<ObservationSnippet?>, time: Binding<Date?>, point: Binding<CLLocation>, hasFocus: Binding<Bool> = .constant(false)) {
        self._observation = observation
        self._time = time
        self._point = point
        self._hasFocus = hasFocus
    }
    @Binding var observation: ObservationSnippet?
    @Binding var time: Date?
    @Binding var point: CLLocation
    private enum FocusedField {
        case waveHeight, wavePeriod, windSpeed, gusts
    }
    @FocusState private var currentField: FocusedField?
    @Binding var hasFocus: Bool
    
    @State private var isLoaded = false
    @State private var marineBuoy: MarineBuoy = .default
    @State private var waveHeight: Double?
    @State private var wavePeriod: TimeInterval?
    @State private var windDirection: CompassDirection = .calm
    @State private var windSpeed: Double?
    @State private var gust: Double?
    var body: some View {
        Section {
            LocationBuoyPicker(buoy: $marineBuoy)
                .swipeActions(edge: .leading) {
                    Button(systemImage: "mappin.circle") {
                        if let nearest = MarineBuoy.offshore.nearest(to: point) {
                            marineBuoy = nearest.value
                        }
                    }
                    .tint(.accentColor)
                }
            LabeledContent("Wave Height") {
                HStack {
                    TextField("Wave Height", value: $waveHeight, format: .number.precision(.fractionLength(0...1)))
                        .multilineTextAlignment(.trailing)
                        .focused($currentField, equals: .waveHeight)
                        .onSubmit {
                            currentField = .wavePeriod
                        }
                        .onChange(of: waveHeight) { oldValue, newValue in
                            updateObservation()
                        }
                        .submitLabel(.next)
                        .keyboardType(.decimalPad)
                    Text("ft")
                }
            }
            LabeledContent("Wave Period") {
                HStack {
                    TextField("Wave Period", value: $wavePeriod, format: .number.precision(.fractionLength(0)))
                        .multilineTextAlignment(.trailing)
                        .focused($currentField, equals: .wavePeriod)
                        .onSubmit {
                            currentField = .windSpeed
                        }
                        .onChange(of: wavePeriod) { oldValue, newValue in
                            updateObservation()
                        }
                        .submitLabel(.next)
                        .keyboardType(.numberPad)
                    Text("sec")
                }
            }
            HStack {
                Picker("Wind Direction", selection: $windDirection) {
                    ForEach(CompassDirection.cardinal, id: \.rawValue) { d in
                        Text(d.abbreviation).tag(d)
                    }
                }
                WindDirectionSymbol(directions: .init(windDirection.direction))
            }
            .onChange(of: windDirection) { oldValue, newValue in
                updateObservation()
            }
            LabeledContent("Wind Speed") {
                HStack {
                    TextField("Wind Speed", value: $windSpeed, format: .number.precision(.fractionLength(0...1)))
                        .multilineTextAlignment(.trailing)
                        .focused($currentField, equals: .windSpeed)
                        .onSubmit {
                            currentField = .gusts
                        }
                        .onChange(of: windSpeed) { oldValue, newValue in
                            updateObservation()
                        }
                        .submitLabel(.next)
                        .keyboardType(.decimalPad)
                    Text("kts")
                }
            }
            LabeledContent("Wind Gusts") {
                HStack {
                    TextField("Wind Gusts", value: $gust, format: .number.precision(.fractionLength(0...1)))
                        .multilineTextAlignment(.trailing)
                        .focused($currentField, equals: .gusts)
                        .onChange(of: gust) { oldValue, newValue in
                            updateObservation()
                        }
                        .keyboardType(.decimalPad)
                        .onSubmit {
                            hasFocus = false
                        }
                    Text("kts")
                }
            }
            if refreshingBuoy {
                ProgressView()
            }
            else {
                Button {
                    refreshBuoy(silently: false)
                } label: {
                    Label("Refresh buoy observation", systemImage: "arrow.clockwise.circle")
                }
                .disabled(!buoyDataAvailable)
            }
        } header: {
            Text("Buoy Observation")
        } footer: {
            if let time = observation?.date {
                HStack {
                    Text(time, format: .dateTime.hour().minute())
                    Spacer()
                    Text(time, format: .dateTime.month(.defaultDigits).day().year())
                }
            }
        }
        .onChange(of: marineBuoy) { oldValue, newValue in
            refreshBuoy()
        }
        .errorAlert(error: $refreshError)
        .onAppear {
            loadViewModels()
        }
        .onChange(of: hasFocus) { oldValue, newValue in
            if newValue {
                currentField = .waveHeight
            }
        }
        .onChange(of: time) { oldValue, newValue in
            refreshBuoy()
        }
    }
    
    private func loadViewModels() {
        if !isLoaded {
            marineBuoy = observation?.buoy?.resolved ?? .default
            waveHeight = observation?.waveHeight
            wavePeriod = observation?.wavePeriod
            windDirection = observation?.compassDirection ?? .calm
            windSpeed = observation?.windSpeed
            gust = observation?.gust
            isLoaded = true
        }
    }
    
    
    
    // MARK: Refresh Observation
    @State private var refreshingBuoy = false
    @State private var refreshError: Error?
    private var buoyDataAvailable: Bool {
        if let time {
            return (-45.day...1.hour).contains(time.timeIntervalSinceNow)
        } else { return false }
    }
    private func refreshBuoy(silently: Bool = true) {
        let service = MarineBuoyWxService()
        if !silently {
            refreshingBuoy = true
        }
        Task {
            do {
                guard let time
                else { throw "Could not fetch buoy data for this time" }
                let wx = try await service.weather(for: marineBuoy).filtering {
                    $0.date <= time
                }
                guard let observation = wx.currentWeather?.snippet(buoy: marineBuoy)
                else { throw "Could not fetch buoy data for this time" }
                await MainActor.run {
                    self.observation = observation
                    waveHeight = observation.waveHeight
                    wavePeriod = observation.wavePeriod
                    windDirection = observation.compassDirection
                    windSpeed = observation.windSpeed
                    gust = observation.gust
                    refreshingBuoy = false
                }
            }
            catch {
                await MainActor.run {
                    if !silently {
                        refreshError = error
                    }
                    refreshingBuoy = false
                }
            }
        }
    }
    func updateObservation() {
        if var observation {
            observation.buoy = marineBuoy.snippet
            observation.waveHeight = waveHeight
            observation.wavePeriod = wavePeriod
            observation.windDirection = windDirection.direction?.converted(to: .degrees).value
            observation.windSpeed = windSpeed
            observation.gust = gust
            self.observation = observation
        }
        else {
            self.observation = .init(date: time ?? .now, buoy: marineBuoy.snippet, airTemperature: nil, waterTemperature: nil, windDirection: windDirection.direction?.converted(to: .degrees).value, windSpeed: windSpeed, gust: gust, waveHeight: waveHeight, wavePeriod: wavePeriod, averageWavePeriod: nil, waveDirection: nil)
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            BuoyObservationEditor(observation: .constant(.random()), time: .constant(.now), point: .constant(.randomOnCoastOfMaine()))
        }
    }
    .locationManager()
}
