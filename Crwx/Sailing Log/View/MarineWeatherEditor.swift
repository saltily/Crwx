//
//  MarineWeatherEditor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/12/24.
//

import SwiftUI
import CoreLocation
import FoundationUI
import FoundationSalt
import WxSalt

struct MarineWeatherEditor: View {
    @Binding var wx: ForecastSnippet?
    @Binding var date: Date
    @Binding var point: CLLocation
    
    @Binding var hasFocus: Bool
    private enum FocusedField {
        case lowWaves, hiWaves
    }
    @FocusState private var currentField: FocusedField?
    
    var body: some View {
        Section {
            LocationMarineZonePicker(zone: $zone)
                .swipeActions(edge: .leading) {
                    Button(systemImage: "mappin.circle") {
                        if let nearest = MarineZone.nearest(to: point)
                        {
                            zone = nearest
                        }
                    }
                    .tint(.accentColor)
                }
                .onChange(of: zone) { oldValue, newValue in
                    refresh()
                }
            
            // MARK: Winds
            ForecastWindLines(winds: $winds, text: wx?.text ?? "")
                .onChange(of: winds) { oldValue, newValue in
                    updateWx()
                }
            
            // MARK: Waves
            LabeledContent("Lower Wave Height") {
                HStack {
                    TextField("2", value: $lowWaves, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .focused($currentField, equals: .lowWaves)
                        .onSubmit {
                            currentField = .hiWaves
                        }
                        .submitLabel(.next)
                    Text("ft")
                }
            }
            .onChange(of: lowWaves) { oldValue, newValue in
                updateWx()
            }
            LabeledContent("Upper Wave Height") {
                HStack {
                    TextField("4", value: $hiWaves, format: .number)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .focused($currentField, equals: .hiWaves)
                        .onSubmit {
                            hasFocus = false
                        }
                        .submitLabel(.next)
                    Text("ft")
                }
            }
            .onChange(of: hiWaves) { oldValue, newValue in
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
            
            // MARK: Refresh
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
            Text("Marine Forecast")
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
                currentField = .lowWaves
            }
        }
    }
    
    
    // MARK: Refreshing
    @State private var isRefreshing = false
    @State private var error: Error?
    private var dataIsAvailable: Bool {
        // usually now to 4 days in the future
        (-1.day...4.day).contains(date.timeIntervalSinceNow)
    }
    private func refresh(silently: Bool = true) {
        let service = MarineZoneWxService()
        if !silently { isRefreshing = true }
        Task {
            do {
                let wx = try await service.weather(for: zone)
                guard let forecast = wx.first(where: {
                    HalfDay(date: $0.date).contains(date)
                }) ?? wx.first(where: {
                    $0.date.withoutTime == date.withoutTime
                })
                else { throw "No marine zone forecast available for this time" }
                let snippet = ForecastSnippet(zone: zone, wx: forecast, date: date)
                await MainActor.run {
                    self.wx = snippet
                    self.importWx(snippet)
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
    
    
    // MARK: Inline view model
    @State private var isLoaded = false
    @State private var zone: MarineZone = .default
    @State private var winds: [WindSnippet] = []
    @State private var lowWaves: Int?
    @State private var hiWaves: Int?
    private func importWx(_ wx: ForecastSnippet?) {
        zone = wx?.zone?.resolved ?? .default
        winds = wx?.winds ?? []
        lowWaves = wx?.lowWaveFeet
        hiWaves = wx?.highWaveFeet
    }
    private func exportWx() -> ForecastSnippet? {
        if var wx {
            wx.date = date
            wx.zone = zone.snippet
            wx.winds = winds
            wx.lowWaveFeet = lowWaves
            wx.highWaveFeet = hiWaves
            return wx
        }
        else {
            return .init(
                date: date,
                zone: zone.snippet,
                winds: winds,
                lowWaveFeet: lowWaves,
                highWaveFeet: hiWaves
            )
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
            MarineWeatherEditor(wx: .constant(.random(true, point: .random)), date: .constant(.now), point: .constant(.randomOnCoastOfMaine()), hasFocus: .constant(false))
        }
    }
    .locationManager()
}
