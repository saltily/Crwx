//
//  LocationChoice.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 12/2/23.
//

import SwiftUI
import FoundationSalt
import WxSalt

enum LocationChoice: Hashable, Codable {
    case saved(UUID)
    case currentLocation
    case custom
}

extension LocationChoice: Defaultable {
    static var `default`: LocationChoice {
        .saved(LocationProfileViewModel.default.id)
    }
}
//extension LocationProfileViewModel {
//    static var allSaved: [LocationProfileViewModel] {
//        [.Machiasport, .Eastport, .Jonesport]
//    }
//    static func find(_ name: String) -> LocationProfileViewModel? {
//        allSaved.first(where: {
//            $0.name == name
//        })
//    }
//}


@propertyWrapper
struct ChosenLocation: DynamicProperty {
    @AppStorage(.locationChoiceKey) private var data: Data?
    var wrappedValue: LocationChoice {
        get { .init(decoding: data) ?? .default }
        nonmutating set { data = newValue.encoded }
    }
    var projectedValue: Binding<LocationChoice> {
        .init {
            wrappedValue
        } set: { newValue in
            wrappedValue = newValue
        }
    }
}

extension String {
    static let locationChoiceKey = "com.saltily.Mewx.locationChoiceKey" // Data?
}
