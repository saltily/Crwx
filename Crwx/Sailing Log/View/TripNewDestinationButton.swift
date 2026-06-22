//
//  TripNewDestinationButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/14/25.
//

import SwiftUI
import FoundationSalt
import WxSalt

struct TripNewDestinationButton: View {
    @Bindable var model: SailingSnapshotViewModel
    @AnchorageIntent private var cachedIntent
    @State private var mutableIntent: VoyageIntent = .init()
    @Environment(\.anchorageSetter) private var setter
    var body: some View {
        NavigationLink(destination: AnchorageChooser(intent: $mutableIntent).seaBackground(.darkSeaGreen).environment(\.anchorageSetter, setter)) {
            
            Image(systemName: "arrow.right.to.line.circle")
            
        }
        .onChange(of: model.currentLocation.coordinate, initial: true) { oldValue, newValue in
            Task {
                var copy = cachedIntent
                copy.setStart(model.startHarbour)
                copy.estimatedDeparture = model.currentTime
                copy.fromLocation = newValue
                copy.estimatedSpeed = model.sog ?? model.smg ?? cachedIntent.estimatedSpeed
                mutableIntent = copy
            }
        }
        .onChange(of: mutableIntent) { oldValue, newValue in
            // for some strange reason this isn't called until we navigate back, and then it is called after the previous change of (thus the Task to offset previous to run after this)
            // pass back to save new speed and direction
            if cachedIntent.estimatedSpeed != newValue.estimatedSpeed {
                cachedIntent.estimatedSpeed = newValue.estimatedSpeed
                model.sog = newValue.estimatedSpeed ~= model.smg ? nil : newValue.estimatedSpeed
            }
            if cachedIntent.directionOfTravel != newValue.directionOfTravel {
                cachedIntent.directionOfTravel = newValue.directionOfTravel
            }
            // block changing of starting point
            if newValue.start != model.startHarbour.id {
                mutableIntent.setStart(model.startHarbour)
            }
            // block changing of departure time
            if newValue.estimatedDeparture != model.currentTime {
                mutableIntent.estimatedDeparture = model.currentTime
            }
        }
    }
    
}
