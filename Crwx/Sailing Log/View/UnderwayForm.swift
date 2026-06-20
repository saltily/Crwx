//
//  UnderwayForm.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationSalt
import FoundationUI
import WxSalt
import SwiftData

struct UnderwayForm: View {
    @State var model: UnderwayViewModel
    let landing: UnderwayButton.Landing
    @State private var locationName: String = ""
    enum FocusedField {
        case windSpeed, depth, tidalCurrent, locationName
    }
    @FocusState private var focusedField: FocusedField?
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationStack {
            List {
                Group {
                    Section("Required") {
                        HStack {
                            Picker("Wind Direction", selection: $model.compassDirection) {
                                ForEach(CompassDirection.cardinal, id: \.rawValue) { d in
                                    Text(d.abbreviation).tag(d)
                                }
                            }
                            WindDirectionSymbol(directions: .init(model.windAngle))
                        }
                        HStack {
                            Text("Wind Speed")
                            let label = model.predictedWindSpeed?.rounded.formatted(.number)
                            TextField(label ?? "Wind Speed", value: $model.windSpeed, format: .number.precision(.fractionLength(0...1)))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .windSpeed)
                                .onSubmit {
                                    focusedField = .depth
                                }
                                .submitLabel(.next)
                            Text("kts")
                        }
                        HStack {
                            Text("Depth")
                            TextField(model.depthPlaceholder(landing) ?? "Depth", value: $model.depth, format: .number.precision(.fractionLength(0...1)))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .depth)
                                .onSubmit {
                                    focusedField = .tidalCurrent
                                }
                                .submitLabel(.next)
                            Text("ft")
                        }
                        HStack {
                            Text("Minimum UKC")
                            Spacer()
                            PlaceholderText(model.ukc, format: .number.precision(.fractionLength(0...1)))
                            Text("ft")
                        }
                        .foregroundStyle(.secondary)
                    }
                    Section("Confirm") {
                        TextField(model.predictedTidalCurrent.nilIfEmpty ?? "Tidal Current", text: $model.tidalCurrent)
                            .textInputAutocapitalization(.never)
                            .focused($focusedField, equals: .tidalCurrent)
                            .onSubmit {
                                focusedField = .locationName
                            }
                            .submitLabel(.next)
                        if let _ = model.location {
                            HStack {
                                Text("Location")
                                TextField("name", text: $locationName)
                                    .multilineTextAlignment(.trailing)
                                    .focused($focusedField, equals: .locationName)
                            }
                        }
//                        HarbourPicker("Harbour", value: $model.harbourId, center: model.location)
                    }
                    UnderwayFetchRow(model: $model, landing: landing)
                }
                .seaSection()
            }
            .listStyle(.grouped)
            .seaBackground(.darkSeaBlue)
            .navigationTitle(landing.rawValue.capitalized)
            .toolbarTitleDisplayMode(.inline)
            .cancelButton()
            .saveButton {
                switch landing {
                case .departure:
                    model.trip?.update(departure: model, context: context)
                case .arrival:
                    model.trip?.update(arrival: model, context: context)
                    try await model.trip?.updateOvernightDepths()
                }
                try context.save()
            }
            .onAppear {
                locationName = model.location?.name ?? ""
                if model.time == nil {
                    model.time = model.trip?.valid(departureTime: .now) ?? .now
                }
                // no autofocus else the virtual keyboard could cover fetch row spinners
            }
            .onChange(of: model.location?.name) { oldValue, newValue in
                locationName = newValue ?? ""
            }
            .onChange(of: locationName) { oldValue, newValue in
                if let _ = model.location {
                    model.location?.name = newValue
                }
            }
        }
    }
}

#Preview {
    List {
        
    }
    .sheet(isPresented: .constant(true)) {
        UnderwayForm(model: .preview(), landing: .departure)
    }
    .locationManager()
}
