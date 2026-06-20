//
//  HarbourInfoEditor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/21/25.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import WxSalt
import SwiftData
import os

struct HarbourInfoEditor: View {
    @Bindable var harbour: Harbour
    let isExpanded: Bool
    @State private var model: HarbourViewModel = .init()
    @State private var cache: HarbourViewModel?
    @Environment(\.modelContext) private var context
    @State private var task: Task<Void,Error>?
    @State private var editGuideRating = false
    var body: some View {
        SwapCondition(isExpanded) {
            List {
                ZeroHeaderSection {
                    
                    // MARK: Name and Tint
                    HStack {
                        TextField("Name", text: $model.name)
                        ColorPicker("Tint", selection: $model.guaranteedColour)
                            .labelsHidden()
                    }
                    
                    // MARK: Region and Position
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Region")
                            Text(model.coastalRegion.rawValue)
                                .foregroundStyle(.secondary)
                                .font(.callout)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(model.latitude, format: .latitude.degrees().labelled().minutes(.fractionLength(1)))
                            Text(model.longitude, format: .longitude.degrees(.wide).labelled().minutes(.fractionLength(1)))
                        }
                        .monospaced()
                        .foregroundStyle(.secondary)
                    }
                    
                    // MARK: Rating and Facilities
                    HStack {
                        Text(editGuideRating ? "Guide Rating" : "Rating")
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editGuideRating.toggle()
                            }
                        Spacer()
                        if editGuideRating {
                            RatingControl(value: $model.guideRating)
                                .foregroundStyle(.red)
                        } else {
                            RatingControl(value: $model.rating, predicted: model.guideRating)
                                .ratingColours()
                        }
                    }
                    FacilitiesPicker(facilities: $model.facilities)
                    
                    // MARK: Protection
                    DisclosureGroup {
                        ProtectionPicker("Score", value: $model.protectionScore)
                        Picker("Bottom", selection: $model.bottom) {
                            Text("Unknown").tag(nil as BottomType?)
                            ForEach(BottomType.allCases, id: \.rawValue) { btm in
                                Text(btm.description).tag(btm)
                            }
                        }
                        ExposurePickerRow("Wind Exposure", exposure: $model.exposure, legend: WindLegend())
                        ExposurePickerRow("Swell Exposure", exposure: $model.swellExposure, legend: WaveLegend())
                        HStack {
                            Text("Chart Depth")
                            Spacer()
                            TextField("0.0", value: $model.depth, format: .number.precision(.fractionLength(0...1)))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                            Text("ft")
                                .foregroundStyle(.secondary)
                        }
                        HStack {
                            Text("Entrance Depth")
                            Spacer()
                            TextField("0.0", value: $model.entranceDepth, format: .number.precision(.fractionLength(0...1)))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                            Text("ft")
                                .foregroundStyle(.secondary)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if let protectionScore = model.protectionScore {
                                    ProtectionSymbol(value: protectionScore)
                                        .tint(.primary)
                                        .opacity(0.8)
                                } else {
                                    Text("Protection")
                                }
                                Spacer()
                                Group {
                                    HarbourAtAGlance.BottomChunk(type: model.bottom, depth: model.depth, entrance: model.entranceDepth)
                                    HarbourAtAGlance.WindChunk(value: model.exposure)
                                    HarbourAtAGlance.SwellChunk(value: model.swellExposure)
                                }
                                .foregroundStyle(.secondary)
                            }
                            .padding(.leading, 2)
                            TextField("Highlights", text: $model.protectionHighlights, axis: .vertical)
                                .font(.subheadline)
                                .lineLimit(2...)
                        }
                    }


                    // Notes
                    TextField("Notes", text: $model.notes, axis: .vertical)
                        .font(.subheadline)
                        .lineLimit(1...)
                }
                .seaSection()
                
                // MARK: Cruising Guide
                Section {
                    NavigationLink(destination: CruisingGuideReader(harbour.name, cruisingGuide: $model.cruisingGuide)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Cruising Guide")
                                    .font(.headline)
                                Spacer()
                                Text(model.cruisingGuide.year, format: .number.grouping(.never))
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                            PlaceholderText(model.cruisingGuide.summary)
                                .lineLimit(1...3)
                                .font(.subheadline)
                        }
                    }
                    if !model.cruisingGuide.anchoring.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Anchoring")
                                .font(.headline)
                            Text(model.cruisingGuide.anchoring)
                                .lineLimit(1...)
                                .font(.subheadline)
                        }
                    }
                    TextField("13309", text: $model.cruisingGuide.charts)
                        .keyboardType(.numbersAndPunctuation)
                        .labeled("Chart Number")
                }
                .seaSection()
            }
            .zeroListHeader(10)
            .padding(.top, 44)
            .onChange(of: harbour, initial: true) { oldValue, newValue in
                if newValue.id != model.id {
                    model = .init(harbour: newValue)
                    cache = model
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .debounceChange(of: $model) { newValue in
                guard newValue != cache else { return }
                save()
            }
            .onDisappear {
                save()
            }
        } off: {
            HarbourAtAGlance(harbour: harbour)
                .padding(harbour.tint == nil ? .horizontal : .trailing)
                .banded(harbour.tint)
        }
    }

    private func save() {
        task?.cancel()
        guard model != cache else { return }
        let container = context.container
        let model = model
        let task = Task.detached {
            let actor = BackModelActor(modelContainer: container)
            try await actor.save(harbour: model)
        }
        self.task = task
        Task {
            do {
                try await task.value
                cache = model
                harbour.update(with: model)
            } catch {
                logger.critical("Couldn't save harbour: \(error)")
            }
        }
    }
}
