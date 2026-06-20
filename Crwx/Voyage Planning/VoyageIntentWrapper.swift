//
//  VoyageIntentWrapper.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/9/25.
//

import SwiftUI
import SwiftData
import FoundationSalt

@propertyWrapper
struct AnchorageIntent: DynamicProperty {
    var wrappedValue: VoyageIntent {
        get {
            Task {
                cached = (start, direction, speed)
            }
            return model ?? assembled
        }
        nonmutating set {
            start = newValue.start
            direction = newValue.directionOfTravel
            speed = newValue.estimatedSpeed
            model = newValue
        }
    }
    var projectedValue: Binding<VoyageIntent> {
        .init {
            wrappedValue
        } set: { newValue in
            wrappedValue = newValue
        }
    }
    @State private var model: VoyageIntent?
    @State private var cached: (UUID?, CompassQuadrant?, Double?)
    func update() {
        let newCache = (start, direction, speed)
        if cached != newCache {
            Task {
                await reload()
            }
        }
    }
    @AppStorage(.voyageIntentStartKey) private var start: UUID = .init()
    @AppStorage(.voyageIntentDirectionKey) private var direction: CompassQuadrant = .west
    @AppStorage(.voyageIntentSpeedKey) private var speed: Double = 2.0
    @Environment(\.modelContext) private var context: ModelContext
    private var harbour: Harbour? {
        if let match = Harbour.find(start, in: context) { return match }
        if let home = try? context.fetchOne(#Predicate<Harbour> {
            $0.name == "Home"
        }) {
            start = home.id
            return home
        }
        return nil
    }
    private var assembled: VoyageIntent {
        .init(harbour: harbour, direction: direction, night: .today, speed: speed)
    }
    @MainActor
    private func reload() async {
        cached = (start, direction, speed)
        model = assembled
    }
}


extension String {
    static let voyageIntentStartKey = "com.saltily.Mewx.voyageIntentStartKey" // UUID
    static let voyageIntentDirectionKey = "com.saltily.Mewx.voyageIntentDirectionKey" // CompassQuadrant
    static let voyageIntentSpeedKey = "com.saltily.Mewx.voyageIntentSpeedKey" // Double
}
