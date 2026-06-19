//
//  UnderwayButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import WxSalt

struct UnderwayButton: View {
    let model: UnderwayViewModel
    let landing: Landing
    let revertable: Bool
    @State private var sheetIsPresented = false
    @State private var confirmRevert = false
    @Environment(\.tripHasArrived) private var hasArrived
    @Environment(\.modelContext) private var context
    var body: some View {
        Section {
            Button {
                sheetIsPresented = true
            } label: {
                
                
                // MARK: Content
                VStack(alignment: .leading, spacing: 8) {
                    
                    if !hasArrived, model.isEmpty {
                        Label(landing.verb.capitalized, systemImage: landing.symbolName)
                            .padding(.vertical)
                    }
                    else {
                        // time and wind
                        HStack {
                            if model.time != nil || hasArrived {
                                PlaceholderText(model.time?.formatted(.dateTime.hour().minute()) ?? "")
                                Spacer()
                                if let harbour = Harbour.find(model.harbourId, in: context) {
                                    SheetButton {
                                        HarbourDetail(harbour: harbour)
                                    } label: {
                                        Image(systemName: "parkingsign.circle")
                                            .fontWeight(.thin)
                                    }
                                    .font(.body)
                                    .tint(.accentColor)
                                }
                                Text(model.location?.name ?? "Unnamed Location")
                            }
                            else {
                                Text("Waiting to \(landing.verb.capitalized)")
                            }
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        Divider()
                        
                        HStack {
                            Text("Wind")
                            Spacer()
                            if let windSpeed = model.windSpeed {
                                Group {
                                    WindDirectionSymbol(directions: .init(model.windAngle))
                                    Text(model.compassDirection.abbreviation)
                                    (Text(windSpeed, format: .number.precision(.fractionLength(0...1))) + Text(" kts"))
                                }
                                //                        .foregroundStyle(.secondary)
                            }
                        }
                        
                        // buoy
                        //                    if let observation = model.observation {
                        //                        BuoyLine(observation: observation)
                        //                            .foregroundColor(.secondary)
                        //                    }
                        
                        // tide and depth
                        HStack(spacing: 20) {
                            Text("Depth")
                            Spacer()
                            if let depth = model.depth {
                                (Text(depth, format: .number.precision(.fractionLength(1))) + Text(" ft"))
                                    .foregroundStyle(.secondary)
                            }
                            Text("UKC")
                            Spacer()
                            if let ukc = model.ukc {
                                (Text(ukc, format: .number.precision(.fractionLength(1))) + Text(" ft"))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // current
                        HStack(spacing: 20) {
                            Text("Tide")
                            Spacer()
                            if let tide = model.tide?.height {
                                (Text(tide, format: .number.precision(.fractionLength(1))) + Text(" ft"))
                                    .foregroundStyle(.secondary)
                            }
                            if !model.tidalCurrent.isEmpty {
                                Text("Current")
                                Spacer()
                                Text(model.tidalCurrent)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(.secondary)
                            }
                        }
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
                Button("Reverse \(landing.rawValue.capitalized)", role: .destructive) {
                    switch landing {
                    case .departure:
                        model.trip?.revertDeparture()
                    case .arrival:
                        model.trip?.revertArrival()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Would you like to reverse this step?\nThis action cannot be undone.")
            }
            .sheet(isPresented: $sheetIsPresented, content: {
                UnderwayForm(model: model, landing: landing)
                    .interactiveDismissDisabled()
                    .scrollDismissesKeyboard(.interactively)
            })
        } header: {
            HStack {
                Text(landing.rawValue.capitalized)
                Spacer()
                if model.isCompleted {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                }
                else {
                    Image(systemName: "cellularbars", variableValue: model.percentComplete)
                }
            }
        }
    }
    enum Landing: String {
        case departure, arrival
        var verb: String {
            switch self {
            case .departure:
                return "depart"
            case .arrival:
                return "arrive"
            }
        }
        var symbolName: String {
            switch self {
            case .departure:
                return "square.and.arrow.up"
            case .arrival:
                return "square.and.arrow.down"
            }
        }
    }
}

#Preview {
    List {
        UnderwayButton(model: .preview(), landing: .departure, revertable: true)
    }
    .locationManager()
    .preferredColorScheme(.dark)
}
