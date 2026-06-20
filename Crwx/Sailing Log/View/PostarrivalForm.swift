//
//  PostarrivalForm.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import WxSalt
import SwiftData

struct PostarrivalForm: View {
    @State var model: PostArrivalViewModel
    private enum FocusedField {
        case mmg, maxSpeed, averageSpeed, odometer, fathoms
    }
    @FocusState private var currentField: FocusedField?
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationStack {
            List {
                Group {
                    Section("Required") {
                        MMGField(milesMadeGood: $model.milesMadeGood, odometer: $model.odometer, averageSpeed: $model.averageSpeed, odometerStart: model.odometerStart, duration: model.duration)
                            .focused($currentField, equals: .mmg)
                            .onSubmit {
                                currentField = .maxSpeed
                            }
                            .submitLabel(.next)
                        HStack {
                            Text("Max Speed")
                            TextField("Max Speed", value: $model.maximumSpeed, format: .number.precision(.fractionLength(0...1)))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .focused($currentField, equals: .maxSpeed)
                                .onSubmit {
                                    currentField = .fathoms
                                }
                                .submitLabel(.next)
                            Text("kts")
                        }
                        FuelEditorRow(model: $model.fuel)
                    }
//                    Section {
//                        
//                        TextField("Comments", text: $model.comments, axis: .vertical)
//                            .lineLimit(5...)
////                            .frame(minHeight: 100, alignment: .leading)
//                            .focused($currentField, equals: .comments)
////                            .onSubmit {
////                                currentField = .averageSpeed
////                            }
////                            .submitLabel(.next)
//                    } header: {
//                        Text("Comments")
//                    } footer: {
//                        if !model.passengers.isEmpty {
//                            Text(model.passengers)
//                        }
//                    }
                    Section("Confirm") {
                        HStack {
                            Text("Average Speed")
                            TextField("Average Speed", value: $model.averageSpeed, format: .number.precision(.fractionLength(0...1)))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .focused($currentField, equals: .averageSpeed)
                                .onSubmit {
                                    currentField = .odometer
                                }
                                .submitLabel(.next)
                            Text("kts")
                        }
                        HStack {
                            Text("Odometer")
                            TextField("Odometer", value: $model.odometer, format: .number.grouping(.never))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .focused($currentField, equals: .odometer)
                            Text("nm")
                        }
                    }
                    Section("Anchoring") {
                        HStack {
                            Text("Anchor Rode")
                            TextField("at the deck", value: $model.fathoms, format: .number.precision(.fractionLength(0...2)))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                                .focused($currentField, equals: .fathoms)
                            Text("ftm")
                        }
                        Group {
                            HStack {
                                Text("Depth")
                                Spacer()
                                PlaceholderText(model.depthRange)
                            }
                            HStack {
                                Text("Scope")
                                Spacer()
                                PlaceholderText(model.scope)
                            }
                            HStack {
                                Text("Swing Radius")
                                Spacer()
                                PlaceholderText(model.maximumSwing?.rounded, format: .number)
                                Text("ft")
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                    if let anchorageName = model.anchorageName {
                        Section("My Notes for \(anchorageName) Anchorage") {
                            TextField("Highlights", text: $model.anchorageHighlights, axis: .vertical)
                                .font(.subheadline)
                                .lineLimit(2...3)
                            TextField("Notes", text: $model.anchorageNotes, axis: .vertical)
                                .font(.subheadline)
                                .lineLimit(2...)
                        }
                    }
                }
                .seaSection()
            }
            .listStyle(.grouped)
            .seaBackground(.darkSeaBlue)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Post Arrival")
            .navigationBarTitleDisplayMode(.inline)
            .cancelButton()
            .saveButton {
                model.fuel?.save(for: model.arrivalTime ?? .now, in: context)
                model.trip?.update(postarrival: model)
                try context.save()
            }
            .onAppear {
                if model.milesMadeGood == nil {
                    currentField = .mmg
                }
                else if model.maximumSpeed == nil {
                    currentField = .maxSpeed
                }
//                else if model.comments.isEmpty {
//                    currentField = .comments
//                }
                else if model.averageSpeed == nil {
                    currentField = .averageSpeed
                }
                else if model.odometer == nil {
                    currentField = .odometer
                }
            }
        }
    }
}

//#Preview {
//    List {
//        
//    }
//    .sheet(isPresented: .constant(true)) {
//        PostarrivalForm(model: .init(comments: "", passengers: "", duration: nil, odometerStart: nil, arrivalTime: nil))
//    }
//    .locationManager()
//    .preferredColorScheme(.dark)
//}


fileprivate struct MMGField: View {
    @Binding var milesMadeGood: Double?
    @Binding var odometer: Int?
    @Binding var averageSpeed: Double?
    let odometerStart: Int?
    let duration: TimeInterval?
    var body: some View {
        HStack {
            Text("MMG")
            TextField("MMG", value: $milesMadeGood, format: .number.precision(.fractionLength(0...1)))
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .onChange(of: milesMadeGood) { oldValue, newValue in
                    if let newValue,
                       let start = odometerStart
                    {
                        odometer = start + newValue.rounded
                    }
                    if let newValue,
                       let duration = duration
                    {
                        averageSpeed = newValue / (duration / .Hour)
                    }
                }
            Text("nm")
        }
    }
}
