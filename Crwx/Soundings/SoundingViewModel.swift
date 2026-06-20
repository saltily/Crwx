//
//  SoundingViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import Foundation
import FoundationSalt

@Observable
final class SoundingViewModel: Identifiable {
    let id = UUID()
    init(date: Date = .now, value: Double? = nil, note: String = "") {
        self.date = date
        self.value = value
        self.note = note
    }
    var date: Date = .now
    var value: Double?
    var note: String = ""
}


extension SoundingViewModel {
    var waterValue: WaterValue? {
        get {
            if let value {
                return .init(rawValue: value)
            }
            return nil
        }
        set {
            self.value = newValue?.rawValue
        }
    }
    var strideableValue: Int {
        get { value?.rounded ?? 0 }
        set {
            if value == nil,
               newValue == 0
            { return }
            value = newValue.double
        }
    }
    var fuelSounding: FuelSounding? {
        get { .init(gallons: value) }
        set {
            value = newValue?.gallons
        }
    }
}
