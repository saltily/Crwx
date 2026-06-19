//
//  PredepartureButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import FoundationSalt

struct PredepartureButton: View {
    let model: PreDepartureViewModel
    @Binding var isAutoloading: Bool
    let revertable: Bool
    @State private var sheetIsPresented = false
    @State private var confirmRevert = false
    var body: some View {
        Section {
            if isAutoloading {
                ProgressView()
                    .frame(height: 50)
            }
            else {
                Button {
                    sheetIsPresented = true
                } label: {
                    
                    
                    // MARK: Content
                    VStack(alignment: .leading, spacing: 10) {
                        if model.isEmpty {
                            Label("Load Weather", systemImage: "icloud.and.arrow.down")
                                .padding(.vertical)
                        }
                        else {
                            Group {
                                TidePredictionLine(predictions: model.tidePredictions)
                                LocalForecastLine(forecast: model.localForecast)
                                MarineForecastLine(forecast: model.marineForecast)
                                BuoyLine(observation: model.buoyObservation)
                            }
                            .foregroundColor(.secondary)
                            Divider()
                            HStack {
                                if let odometer = model.odometer {
                                    Text(odometer, format: .number.grouping(.never)) + Text(" nm")
                                }
                                Spacer()
                                if let fuel = model.fuel,
                                   let inches = fuel.inches
                                {
                                    Text(inches.eighths) + Text(" in")
                                    Text(fuel.gallons ?? 0, format: .number.precision(.fractionLength(1))) + Text(" gals")
                                }
                            }
                            .foregroundColor(.secondary)
                            HStack {
                                DinghyView(dinghy: model.dinghy)
                                Spacer()
                                Text(model.passengers)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    
                }
                .tint(model.isEmpty ? .accentColor : .primary)
                .swipeActions(allowsFullSwipe: false) {
                    if revertable && !model.isEmpty {
                        Button(systemImage: "trash") {
                            confirmRevert = true
                        }
                        .tint(.red)
                    }
                }
                .confirmationDialog("Confirm Clear", isPresented: $confirmRevert) {
                    Button("Reset Trip", role: .destructive) {
                        model.trip?.revertPredeparture()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Would you like to reset this trip?\nThis action cannot be undone.")
                }
                .sheet(isPresented: $sheetIsPresented, content: {
                    PredepartureForm(model: model)
                        .interactiveDismissDisabled()
                        .scrollDismissesKeyboard(.interactively)
                })
            }
        } header: {
            HStack {
                Text("Pre-Departure")
                Spacer()
                if model.isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                }
                else {
                    Image(systemName: "cellularbars", variableValue: model.percentComplete)
                }
            }
        } footer: {
            if let location = model.localForecast?.point {
                HStack {
                    Text(location.name ?? "")
                    Spacer()
                    Text(location.coordinate, format: .location.minutes().precision(.fractionLength(1)))
                }
            }
        }
    }
}

#Preview {
    List {
        PredepartureButton(model: .preview(), isAutoloading: .constant(false), revertable: true)
    }
    .preferredColorScheme(.dark)
    .locationManager()
}



// MARK: Dinghy
fileprivate struct DinghyView: View {
    let dinghy: DinghyOption
    var body: some View {
        switch dinghy {
        case .none:
            Text("No Dinghy")
        case .white:
            Text("White Dinghy")
        case .green:
            Text("Green Dinghy")
        }
    }
}
