//
//  TripMapper.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 5/7/25.
//

import Foundation
import FoundationUI
import FoundationSalt
import SwiftUI
import MapKit

/// This is just something to consolidate and cache all of the pieces that we might display on a map for the trip, such as route, track, start, end, and logged events along the way.
struct TripMapper {
    let start: LocationSnippet?
    let end: LocationSnippet?
    let route: RouteSnippet?
    let track: [TrackPoint]
    let events: [LocationSnippet]
}

extension TripMapper {
    var points: [any Mappable] {
        var points = [(any Mappable)?]()
        points.append(start)
        points.append(end)
        points.append(contentsOf: route?.points ?? [])
        points.append(contentsOf: track)
        points.append(contentsOf: events)
        return points.compactMap { $0 }
    }
}

extension Trip {
    var mapper: TripMapper {
        .init(
            start: timestampedDepartureLocation,
            end: timestampedArrivalLocation,
            route: route,
            track: track?.points ?? [],
            events: events.compactMap {
                guard let coordinate = $0.location
                else { return nil }
                return .init(name: $0.time.formatted(.dateTime.hour().minute()), point: coordinate)
            }
        )
    }
}
extension MapBasket {
    func render(trip: TripMapper) {
        
        // grey route line
        if let route = trip.route {
            line(route.points, .gray)
        }
        
        // red track line
        if !trip.track.isEmpty {
            line(trip.track)
        }
        
        // small dots for events
        for event in trip.events {
            dot(event, tint: .black, width: 6, border: 1)
        }
        
        // big dots for ends
        if let start = trip.start {
            dot(start, tint: .gray)
        }
        if let end = trip.end {
            dot(end)
        }
        
    }
}

struct TripMapContent: MapContent {
    let trip: TripMapper
    var body: some MapContent {
        
        // grey route line
        if let route = trip.route {
            Polyline(route.points, tint: .gray)
        }
        
        // red track line
        if !trip.track.isEmpty {
            Polyline(trip.track)
        }
        
        // small dots for events
        ForEach(0..<trip.events.count, id: \.self) { i in
            MapDot(trip.events[i], tint: .black, width: 6, border: 1)
        }
        
        // big dots for ends
        if let start = trip.start {
            MapDot(start, tint: .gray)
        }
        if let end = trip.end {
            MapDot(end)
        }
        
    }
}

struct TripMap: View {
    @Binding var region: MKCoordinateRegion
    var marker: (any Mappable)?
    @Environment(\.tripMapper) private var trip
    var body: some View {
        SafeChartMap(region: $region) {
            if let trip {
                TripMapContent(trip: trip)
            }
            if let marker {
                Marker(marker)
            }
        } legacy: { map in
            if let trip {
                map.render(trip: trip)
            }
            if let marker {
                map.marker(point: marker)
            }
        }
        .onChange(of: region, initial: true) { oldValue, newValue in
            if newValue == .init() {
                if let trip {
                    var points = trip.points
                    if let marker {
                        points.append(marker)
                    }
                    region = .fitting(points: points)
                } else if let marker {
                    region = .init(center: marker, diameter: .init(value: 1, unit: .nauticalMiles))
                } else {
                    region = .MaineCoast
                }
            }
        }
    }
}

extension EnvironmentValues {
    struct TripMapperKey: EnvironmentKey {
        static var defaultValue: TripMapper? {
            return nil
        }
    }
    var tripMapper: TripMapper? {
        get { self[TripMapperKey.self] }
        set { self[TripMapperKey.self] = newValue }
    }
}

