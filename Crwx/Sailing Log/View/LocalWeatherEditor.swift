//
//  LocalWeatherEditor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/12/24.
//

import SwiftUI
import CoreLocation
import WeatherKit
import FoundationUI
import FoundationSalt
import WxSalt

struct LocalWeatherEditor: View {
    @Binding var wx: ForecastSnippet?
    @Binding var date: Date
    @Binding var point: CLLocation
    
    @Binding var hasFocus: Bool
    private enum FocusedField {
        case locationName, temperature
    }
    @FocusState private var currentField: FocusedField?
    
    var body: some View {
        Section {
            
            // MARK: Symbol
            Picker("Symbol", selection: $symbol) {
                ForEach(WxSymbol.wxCases, id: \.rawValue) { s in
                    Label(s.description, systemImage: s.rawValue).tag(s)
                        .symbolVariant(.fill)
                }
            }
            .onChange(of: symbol) { oldValue, newValue in
                updateWx()
            }

            
            // MARK: Location
            LocationPointPicker(point: $point) { name in
                if locationName.isEmpty {
                    locationName = name
                    updateWx()
                    refresh()
                }
            }
            .swipeActions(edge: .leading) {
                Button(systemImage: "mappin.circle") {
                    fetchCurrentLocation()
                }
                .tint(.accentColor)
            }
            .onChange(of: point) { oldValue, newValue in
                updatePoint()
            }
            LabeledContent("Location Name") {
                TextField("Name", text: $locationName)
                    .multilineTextAlignment(.trailing)
                    .autocorrectionDisabled()
                    .submitLabel(.next)
            }
            .focused($currentField, equals: .locationName)
            .onSubmit {
                updateWx()
                currentField = .temperature
            }
            .onDisappear {
                updateWx()
            }
            
            // MARK: Temperature
            LabeledContent("High Temperature") {
                HStack {
                    TextField("60", value: $temperature, format: .number.precision(.fractionLength(0)))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .submitLabel(.next)
                    Text("º")
                }
            }
            .focused($currentField, equals: .temperature)
            .onSubmit {
                hasFocus = false
            }
            .onChange(of: temperature) { oldValue, newValue in
                updateWx()
            }

            // MARK: Wind
            ForecastWindLines(winds: $winds, text: wx?.text ?? "")
                .onChange(of: winds) { oldValue, newValue in
                    updateWx()
                }
            
            // MARK: Text
            if let wx,
               !wx.text.isEmpty
            {
                VStack(alignment: .leading) {
                    Text("Text Forecast")
                    Text(wx.text)
                        .textSelection(.enabled)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 3)
                }
            }

            // MARK: Refreshing
            if isRefreshing {
                ProgressView()
            }
            else {
                Button {
                    refresh(silently: false)
                } label: {
                    Label("Refresh forecast", systemImage: "arrow.clockwise.circle")
                }
                .disabled(!dataIsAvailable)
            }
        } header: {
            HStack {
                Text("Local Forecast")
                Spacer()
                Image(systemName: symbol.rawValue)
                    .renderingMode(.original)
                    .symbolVariant(.fill)
                    .font(.title)
                    .frame(height: 20)
            }
        } footer: {
            if let time = wx?.date {
                HStack {
                    Text(time, format: .dateTime.hour().minute())
                    Spacer()
                    Text(time, format: .dateTime.month(.defaultDigits).day().year())
                }
            }
        }
        .onAppear {
            if !isLoaded {
                importWx(wx)
                isLoaded = true
            }
        }
        .errorAlert(error: $error)
        .onChange(of: date) { oldValue, newValue in
            refresh()
        }
        .onChange(of: hasFocus) { oldValue, newValue in
            if newValue {
                currentField = .locationName
            }
        }
    }
    
    // MARK: Refreshing
    @State private var isRefreshing = false
    @State private var error: Error?
    private var dataIsAvailable: Bool {
        // Apple weather goes back a ways
        (-33.month...9.day).contains(date.timeIntervalSinceNow)
    }
    private func refresh(silently: Bool = true) {
        if !silently { isRefreshing = true }
        Task {
            do {
                let wx = try await ForecastSnippet.fetchLocal(for: newPoint, at: date)
                await MainActor.run {
                    self.wx = self.wx?.updating(with: wx) ?? wx
                    self.importWx(wx)
                    isRefreshing = false
                }
            }
            catch {
                await MainActor.run {
                    if !silently {
                        self.error = error
                    }
                    isRefreshing = false
                }
            }
        }
    }
    @PositionTracker private var tracker
    private func fetchCurrentLocation() {
        Task {
            if let current = await tracker.currentLocation { // ?? .randomOnCoastOfMaine()
                point = current
            }
        }
    }
    private var oldPoint: LocationSnippet? {
        wx?.point
    }
    private var newPoint: LocationSnippet {
        .init(name: locationName, latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
    }
    private func updatePoint() {
        if let oldPoint,
               oldPoint.distance(to: point).converted(to: .nauticalMiles).value > 0.25
        {
            locationName = ""
        }
        updateWx()
    }

    
    
    // MARK: Inline view model
    @State private var isLoaded = false
    @State private var locationName: String = ""
    @State private var symbol: WxSymbol = .cloudy
    @State private var temperature: Double?
    @State private var winds: [WindSnippet] = []
    private func importWx(_ wx: ForecastSnippet?) {
        locationName = wx?.point?.name ?? ""
        symbol =
        if let symbolName = wx?.symbolName,
           let symbol = WxSymbol(rawValue: symbolName)
        {
            symbol
        } else { .cloudy }
        temperature = wx?.highTemperature
        winds = wx?.winds ?? []
    }
    private func exportWx() -> ForecastSnippet? {
        if var wx {
            wx.date = date
            wx.point = newPoint
            wx.symbolName = symbol.rawValue
            wx.highTemperature = temperature
            wx.winds = winds
            return wx
        }
        else {
            return .init(date: date, point: newPoint, zone: .zero, symbolName: symbol.rawValue, highTemperature: temperature, winds: winds)
        }
    }
    private func updateWx() {
        wx = exportWx()
    }
}

// MARK: Preview
#Preview {
    NavigationStack {
        Form {
            LocalWeatherEditor(wx: .constant(.random(point: .random)), date: .constant(.now), point: .constant(.randomOnCoastOfMaine()), hasFocus: .constant(false))
        }
    }
    .preferredColorScheme(.dark)
    .locationManager()
}
