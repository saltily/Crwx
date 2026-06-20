//
//  MarineWeatherBrowser.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/16/25.
//

import SwiftUI
import FoundationSalt
import CoreLocation
import WxSalt

struct MarineWeatherBrowser: View {
    init(location: CLLocation?) {
        if let location,
           let zone = MarineZone.nearest(to: location)
        {
            _zone = .init(initialValue: zone)
        } else {
            _zone = .init(initialValue: .default)
        }
    }
    @State private var zone: MarineZone
    @State private var forecast: MarineZoneWxForecast?
    let forecasts = CoastalForecasts()
    @StateObject private var task = PerformTask<MarineZoneWxForecast?>(multiple: .skipsIfRunning)
    var body: some View {
        List {
            Section {
                LocationMarineZonePicker(zone: $zone)
            } footer: {
                if let captured = forecast?.captured {
                    Text("Last updated: ") +
                    Text(captured, format: .dateTime)
                }
            }
            .seaSection()
            
            if let synopsis = forecast?.synopsis.nilIfEmpty {
                Section {
                    Text(synopsis)
                } header: {
                    Text("Synopsis")
                } footer: {
                    if let captured = forecast?.captured {
                        Text(captured.half.weekday)
                    }
                }
                .seaSection()
            }
            
            if let advisories = forecast?.advisories,
               !advisories.isEmpty
            {
                Section("Advisories") {
                    ForEach(advisories, id: \.self) { t in
                        Text(t)
                    }
                }
                .seaSection()
            }
            
            Section("Forecast") {
                if task.isRunning {
                    ProgressView()
                }
                ForEach(wx, id: \.date) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.date.half.weekday)
                            .font(.headline)
                        Text(entry.summary)
                    }
                }
            }
            .seaSection()
        }
        .onChange(of: zone, initial: true) { oldValue, newValue in
            load()
        }
        .refreshable {
//            await forecasts.set(offline: false)
            forecast = await forecasts.marineWeather(for: zone)
        }
    }
    private var wx: [MarineZoneWeather] {
        guard let forecast else { return [] }
        let earliest: Date = Date.now.timeAsInterval < 6.hour ? Date.now.yesterday.withoutTime.addingTimeInterval(18.hour) : Date.now.withoutTime
        return forecast.forecast.filter {
            $0.date >= earliest
        }
    }
    private func load() {
        task.perform {
            await forecasts.marineWeather(for: zone)
        } then: { wx in
            self.forecast = wx
        }
    }
}
