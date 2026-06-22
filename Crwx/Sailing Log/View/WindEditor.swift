//
//  WindEditor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/12/24.
//

import SwiftUI
import FoundationSalt
import WxSalt

struct WindEditor: View {
    @Binding var wind: WindSnippet
    let text: String
    var body: some View {
        List {
            Group {
                Section("Wind") {
                    HStack {
                        Picker("Wind Direction", selection: $wind.compassDirection) {
                            ForEach(CompassDirection.cardinal, id: \.rawValue) { d in
                                Text(d.abbreviation).tag(d)
                            }
                        }
                        WindDirectionSymbol(directions: .init(wind.angle))
                    }
//                    .padding(.vertical, 3)
                    HStack {
                        Stepper("Low Speed", value: $lowWind, in: 0...99)
                        TextField("10", value: $lowWind, format: .number.precision(.fractionLength(0)))
                            .multilineTextAlignment(.trailing)
                            .frame(width: 30)
                            .keyboardType(.numberPad)
                        Text("kts")
                            .foregroundStyle(.secondary)
                    }
//                    .padding(.vertical, 3)
                    .onChange(of: lowWind) { oldValue, newValue in
                        if hiWind < newValue {
                            hiWind = newValue
                        }
                        wind.speed = newValue.double..<hiWind.double
                    }
                    HStack {
                        Stepper("High Speed", value: $hiWind, in: 0...99)
                        TextField("15", value: $hiWind, format: .number.precision(.fractionLength(0)))
                            .multilineTextAlignment(.trailing)
                            .frame(width: 30)
                            .keyboardType(.numberPad)
                        Text("kts")
                            .foregroundStyle(.secondary)
                    }
//                    .padding(.vertical, 3)
                    .onChange(of: hiWind) { oldValue, newValue in
                        // this triggers too often - change 12 to 10 and it is 1 in between and that would lower the upper value
//                        if lowWind > newValue {
//                            lowWind = newValue
//                        }
                        if newValue >= lowWind {
                            wind.speed = lowWind.double..<newValue.double
                        }
                    }
                    LabeledContent("Gusts") {
                        HStack {
                            TextField("25", value: $wind.gust, format: .number.precision(.fractionLength(0)))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                            Text("kts")
                        }
                    }
//                    .padding(.vertical, 8)
                }
                if !text.isEmpty {
                    Section("Text Forecast") {
                        Text(text)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 3)
                    }
                }
            }
            .seaSection()
        }
        .listStyle(.grouped)
        .seaBackground(.flat)
        .navigationTitle("Edit Wind")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            lowWind = wind.speed.lowerBound.rounded
            hiWind = wind.speed.upperBound.rounded
        }
    }
    
    
    // MARK: View Model
    @State private var lowWind: Int = 10
    @State private var hiWind: Int = 15
    
}

#Preview {
    NavigationStack {
        WindEditor(wind: .constant(.random), text: "Some sort of forecast")
    }
}
