//
//  HarbourViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/14/25.
//

import SwiftUI
import CoreLocation
import FoundationSalt
import SwiftData

struct HarbourViewModel: Identifiable, Sendable, Mappable, Equatable {
    var persistentId: PersistentIdentifier?
    let id: UUID
    var name: String = ""
    let latitude: Double
    let longitude: Double
    var formattedAddress: String? { nil }
    var tint: Color?
    var bottom: BottomType?
    var depth: Double?
    var entranceDepth: Double?
    var exposure: CompassExposure = .init()
    var swellExposure: CompassExposure = .init()
    var notes: String = ""
    var rating: Double?
    var facilities: Facilities = .init()
    var protectionScore: ProtectionScore?
    var protectionHighlights: String = ""
    var cruisingGuide: CruisingGuide = .init()
    var guideRating: Double?
    // weather locations
    
    var distanceFromStart: Double = 0
    var route: RouteSnippet?
    var quadrantsFromStart: Set<CompassQuadrant> = []
    var isGenerated: Bool {
        guard let route else { return true }
        return route.generated
    }
}
extension Harbour {
    func update(with viewModel: HarbourViewModel) {
        name = viewModel.name
        waypoint?.tint = viewModel.tint
        bottomType = viewModel.bottom
        chartDepth = viewModel.depth
        entranceDepth = viewModel.entranceDepth
        windExposure = viewModel.exposure
        swellExposure = viewModel.swellExposure
        notes = viewModel.notes
        rating = viewModel.rating
        facilities = viewModel.facilities
        protectionScore = viewModel.protectionScore
        protectionHighlights = viewModel.protectionHighlights
        cruisingGuide = viewModel.cruisingGuide
        guideRating = .init(percentage: viewModel.guideRating)
    }
}

extension HarbourViewModel {
    var guaranteedColour: Color {
        get { tint ?? .black }
        set { tint = newValue }
    }
}

extension HarbourViewModel {
    init() {
        self.id = .init()
        let location = CLLocation.default
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
    init(coordinate: CLLocationCoordinate2D) async {
        self.id = .init()
        self.name = await coordinate.name
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    init(harbour: Harbour) {
        persistentId = harbour.persistentModelID
        id = harbour.id
        name = harbour.name
        latitude = harbour.latitude
        longitude = harbour.longitude
        tint = harbour.waypoint?.tint ?? harbour.waypoint?.symbol?.colour
        bottom = harbour.bottomType
        depth = harbour.chartDepth
        entranceDepth = harbour.entranceDepth
        exposure = harbour.windExposure
        swellExposure = harbour.swellExposure
        notes = harbour.notes
        rating = harbour.rating
        facilities = harbour.facilities
        protectionScore = harbour.protectionScore
        protectionHighlights = harbour.protectionHighlights
        guideRating = harbour.guideRating?.percentage
        cruisingGuide = harbour.cruisingGuide
    }
    init(start: Waypoint, destination: Waypoint, routes: RouteLoader) async {
        id = destination.id
        name = destination.name
        latitude = destination.latitude
        longitude = destination.longitude
        tint = destination.symbol?.colour
        
        if let route = try? await routes.route(from: start.persistentModelID, to: destination.persistentModelID) {
            self.route = route
            self.distanceFromStart = route.distance
        } else {
            self.distanceFromStart = start.distance(to: destination).converted(to: .nauticalMiles).value
        }
        
        var quadrants = Set<CompassQuadrant>()
        let threshold = 0.000_01
        if destination.longitude.rounded(threshold) < start.longitude.rounded(threshold) { quadrants.insert(.west) }
        if destination.longitude.rounded(threshold) > start.longitude.rounded(threshold) { quadrants.insert(.east) }
        if destination.latitude.rounded(threshold) < start.latitude.rounded(threshold) { quadrants.insert(.south) }
        if destination.latitude.rounded(threshold) > start.latitude.rounded(threshold) { quadrants.insert(.north) }
        quadrantsFromStart = quadrants
    }
}

extension HarbourViewModel {
    var label: String? { name }
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    static func make(from point: any Mappable) -> HarbourViewModel? {
        point as? HarbourViewModel
    }
}
