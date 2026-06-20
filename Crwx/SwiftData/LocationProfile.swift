//
//  LocationProfile.swift
//  Mewx
//
//  Created by Matthew Goacher on 2/13/25.
//

import Foundation
import SwiftData
import CoreLocation
import WxSalt
import FoundationSalt

public typealias LocationProfile = CurrentSchema.LocationProfile

extension LocationProfile {
    var point: CLLocation {
        get { .init(latitude: latitude, longitude: longitude) }
        set {
            latitude = newValue.coordinate.latitude
            longitude = newValue.coordinate.longitude
        }
    }
    var marinePoint: CLLocation {
        get { .init(latitude: marineLatitude, longitude: marineLongitude) }
        set {
            marineLatitude = newValue.coordinate.latitude
            marineLongitude = newValue.coordinate.longitude
        }
    }
    var zone: MarineZone {
        get { .init(decoding: _zone) ?? .default }
        set { _zone = newValue.encoded }
    }
    var buoy: MarineBuoy {
        get { .init(decoding: _buoy) ?? .default }
        set { _buoy = newValue.encoded }
    }
    var tides: TideStation {
        get { .init(decoding: _tides) ?? .default }
        set { _tides = newValue.encoded }
    }
    var currents: TidalCurrentStation {
        get { .init(decoding: _currents) ?? .default }
        set { _currents = newValue.encoded }
    }
    var airport: WeatherStation {
        get { .init(rawValue: observations) ?? .default }
        set { observations = newValue.rawValue }
    }
}


// MARK: Fetching
extension LocationProfile {
    static func find(_ id: UUID?, in context: ModelContext) -> LocationProfile? {
        guard let id else { return nil }
        return try? context.fetchOne(#Predicate {
            $0.id == id
        })
    }
}
extension [SortDescriptor<LocationProfile>] {
    static var defaultSortOder: Self {
        [
            .init(\.index)
        ]
    }
}


// MARK: Make from View Model
extension LocationProfile {
    convenience init(viewModel: LocationProfileViewModel) {
        self.init(
            id: viewModel.id,
            name: viewModel.name,
            index: viewModel.index,
            latitude: viewModel.point.coordinate.latitude,
            longitude: viewModel.point.coordinate.longitude,
            observations: viewModel.observations.rawValue,
            marineLatitude: viewModel.marinePoint.coordinate.latitude,
            marineLongitude: viewModel.marinePoint.coordinate.longitude,
            _zone: viewModel.zone.encoded,
            _buoy: viewModel.buoy.encoded,
            _tides: viewModel.tides.encoded,
            _currents: viewModel.currents.encoded
        )
    }
}
extension LocationProfileViewModel: @retroactive Backupable {
    public func insert(into context: ModelContext) throws {
        let new = LocationProfile(viewModel: self)
        context.insert(new)
    }
    public init(persistentModel: LocationProfile) {
        self.init(
            persistentId: persistentModel.persistentModelID,
            id: persistentModel.id,
            name: persistentModel.name,
            index: persistentModel.index,
            point: persistentModel.point,
            observations: persistentModel.airport,
            marinePoint: persistentModel.marinePoint,
            zone: persistentModel.zone,
            buoy: persistentModel.buoy,
            tides: persistentModel.tides,
            currents: persistentModel.currents
        )
    }
}
extension LocationProfileViewModel {
    static func bestFor(tideStation: TideStation, in context: ModelContext, choice: inout LocationChoice) async -> LocationProfileViewModel {
        if let existingMatch = (try? context.fetch(LocationProfile.self))?.first(where: {
            $0.tides.id == tideStation.id
        }) {
            choice = .saved(existingMatch.id)
            return .init(persistentModel: existingMatch)
        }
        var new = await LocationProfileViewModel(point: tideStation.location)
        new.tides = tideStation
        choice = .custom
        return new
    }
}
