//
//  TidePredictionsEditor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/14/24.
//

import SwiftUI
import CoreLocation
import FoundationUI
import FoundationSalt
import WxSalt

struct TidePredictionsEditor: View {
    @Binding var predictions: [TidePredictionSnippet]
    @Binding var date: Date
    @Binding var point: CLLocation
    
    @Binding var hasFocus: Bool
    @State var currentField: Int?

    @State private var tideStation: TideStation = .default
    var body: some View {
        Section {
            // MARK: Tide Station
            LocationTideStationPicker(station: $tideStation)
                .swipeActions(edge: .leading) {
                    Button(systemImage: "mappin.circle") {
                        if let station = TideStation.all.nearest(to: point) {
                            tideStation = station.value
                        }
                    }
                    .tint(.accentColor)
                }
                .onChange(of: tideStation) { oldValue, newValue in
                    refresh()
                    // embed the station in the predictions if not refreshed
                    let snippet = newValue.snippet
                    let newPredictions: [TidePredictionSnippet] = predictions.map {
                        var copy = $0
                        copy.station = snippet
                        return copy
                    }
                    if newPredictions != predictions {
                        predictions = newPredictions
                    }
                }
            
            // MARK: Tides
            ForEach(0..<predictions.count, id: \.self) { i in
                TideEditorRow(tide: $predictions[i], focused: $currentField, equals: i)
                // swipe to delete
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        predictions.remove(at: i)
                    }
                }
            }
            .onChange(of: currentField, { oldValue, newValue in
                if newValue >= predictions.count {
                    currentField = nil
                    hasFocus = false
                }
            })
            .onDisappear {
                let sorted = predictions.sorted()
                if sorted != predictions {
                    predictions = sorted
                }
            }
            // add up to four
            if predictions.count < 4 {
                Button {
                    // try 1 minute after last, else if empty go with midnight
                    var d = predictions.last?.date.addingTimeInterval(1.minute) ?? date.withoutTime
                    // if the day changed, go back to midnight
                    if d.withoutTime != date.withoutTime {
                        d = date.withoutTime
                    }
                    // make a prediction
                    let p = TidePredictionSnippet(date: d, height: 0, isHi: predictions.last?.isHi == false ? true : false, station: tideStation.snippet)
                    // add to a copy
                    var copy = predictions
                    copy.append(p)
                    // sort and store
                    predictions = copy.sorted()
                } label: {
                    Label("Add tide prediction", systemImage: "plus")
                }
            }
            
            // MARK: Refresh button
            if isRefreshing {
                ProgressView()
            }
            else {
                Button {
                    refresh(silently: false)
                } label: {
                    Label("Refresh tides", systemImage: "arrow.clockwise.circle")
                }
            }

        } header: {
            Text("Tide Predictions")
        } footer: {
            Text(date, format: .dateTime.weekday(.wide).month(.wide).day().year())
        }
        .errorAlert(error: $error)
        .onAppear {
            tideStation = predictions.first?.station?.resolved ?? .default
        }
        .onChange(of: hasFocus) { oldValue, newValue in
            if newValue {
                currentField = 0
            }
        }
    }
    
    
    // MARK: Refresh
    @State private var isRefreshing = false
    @State private var error: Error?
    private func refresh(silently: Bool = true) {
        let service = TideWxService()
        if !silently {
            isRefreshing = true
        }
        Task {
            do {
                let tides = try await service.weather(for: tideStation, from: date.addingTimeInterval(-2.day), to: date.addingTimeInterval(2.day))
                let predictions = tides.predictions(for: date.day)
                guard !predictions.isEmpty
                else { throw "Could not find tide data for this time" }
                await MainActor.run {
                    self.predictions = predictions.snippets(station: tideStation.snippet)
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
    
}

#Preview {
    NavigationStack {
        Form {
            TidePredictionsEditor(predictions: .constant(.random(on: .now)), date: .constant(.now), point: .constant(.randomOnCoastOfMaine()), hasFocus: .constant(false))
        }
    }
    .locationManager()
    .preferredColorScheme(.dark)
}
