//
//  TripDestinationPicker.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/9/25.
//

import SwiftUI
import SwiftData
import WxSalt

/// - swipe for a daysail loop to original
/// - disabled if no start
/// - navigates to anchorage chooser using cached intent and model start - change that when model start changes
struct TripDestinationPicker: View {
    @Binding var model: TripRouteViewModel
    @AnchorageIntent private var cachedIntent
    @State private var mutableIntent: VoyageIntent = .init()
    @Environment(\.modelContext) private var context
    @State private var destinationSetter: Destination = .init()
    var body: some View {
        // navigate to chooser
        NavigationLink(destination: AnchorageChooser(intent: $mutableIntent).seaBackground(.darkSeaGreen).environment(\.anchorageSetter, destinationSetter)) {
            
            Text("Destination")
                .badge(endHarbour?.name ?? "")
            
        }
        // only allow using the chooser when the trip has a starting point
        .disabled(model.start == nil)
        .onChange(of: model.start, initial: true) { oldValue, newValue in
            // ensure chooser uses the trip's starting point
            if let startHarbour {
                var copy = cachedIntent
                copy.setStart(startHarbour)
                mutableIntent = copy
            }
        }
        .onChange(of: mutableIntent) { oldValue, newValue in
            // pass back to save new speed and direction
            if cachedIntent.estimatedSpeed != newValue.estimatedSpeed {
                cachedIntent.estimatedSpeed = newValue.estimatedSpeed
            }
            if cachedIntent.directionOfTravel != newValue.directionOfTravel {
                cachedIntent.directionOfTravel = newValue.directionOfTravel
            }
            // block changing of starting point
            if let start = model.start,
               newValue.start != start
            {
                mutableIntent.start = start
            }
        }
        .onAppear {
            destinationSetter.save = { potential in
                model.destination = potential.destination
                model.route = potential.route
            }
        }
        
    }
    private var startHarbour: Harbour? {
        Harbour.find(model.start, in: context)
    }
    private var endHarbour: Harbour? {
        Harbour.find(model.destination, in: context)
    }
    
    @Observable
    final class Destination {
        init(save: @escaping (AnchoragePotential) -> Void = { _ in }) {
            self.save = save
        }
        var save: (AnchoragePotential) -> ()
    }
}

extension EnvironmentValues {
    struct DestinationSetterKey: EnvironmentKey {
        static var defaultValue: TripDestinationPicker.Destination? {
            return nil
        }
    }
    var anchorageSetter: TripDestinationPicker.Destination? {
        get { self[DestinationSetterKey.self] }
        set { self[DestinationSetterKey.self] = newValue }
    }
}

