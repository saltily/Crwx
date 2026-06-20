//
//  StopActions.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/7/25.
//

import SwiftUI
import FoundationUI
import MapKit
import SwiftData
import FoundationSalt

struct StopActions: ViewModifier {
    let i: Int
    @Bindable var model: CruiseViewModel
    @Binding var region: MKCoordinateRegion
    @State private var isPresented = false
    @State private var actionType: ActionType = .insert
    @State private var selectedHarbour: UUID?
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var harbours: [Harbour]
    func body(content: Content) -> some View {
        content
            .actions {
                if model.canInsert(after: i) {
                    Button("Insert Stop", systemImage: "plus.square.on.square") {
                        selectedHarbour = nil
                        actionType = .insert
                        isPresented = true
                    }
                }
                if model.canMove(i) {
                    Button("Move Stop", systemImage: "arrow.down.right") {
                        selectedHarbour = nil
                        actionType = .move
                        isPresented = true
                    }
                }
                Divider()
                RemoveStopButton(i: i, model: model)
            }
            .navigationDestination(isPresented: $isPresented) {
                HarbourPickerMap(selection: $selectedHarbour, harbours: harbours, initialRegion: initialRegion)
                    .navigationTitle(actionType == .insert ? "Insert Stop" : "Move Stop")
            }
            .onChange(of: selectedHarbour) { oldValue, newValue in
                if oldValue == nil,
                   let newValue,
                   let new = Harbour.find(newValue, in: context)
                {
                    switch actionType {
                    case .move:
                        model.move(i, to: new)
                    case .insert:
                        model.insert(harbour: new, after: i)
                    }
                    region = model.region
                    dismiss()
                }
            }

    }
    private var initialRegion: MKCoordinateRegion {
        if model.anchorages.count > (i+1) {
            return .init(center: model.anchorages[i+1], diameter: .init(value: 10, unit: .nauticalMiles))
        } else {
            return model.region
        }
    }
    enum ActionType {
        case move, insert
    }
}
extension View {
    func cruiseActions(_ i: Int, model: CruiseViewModel, region: Binding<MKCoordinateRegion>) -> some View {
        modifier(StopActions(i: i, model: model, region: region))
    }
}
