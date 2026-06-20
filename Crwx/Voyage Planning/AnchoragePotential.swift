//
//  AnchoragePotential.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/27/25.
//

import Foundation
import FoundationSalt
import CoreLocation
import SwiftUI
import WxSalt

/// Let's give it an initialiser and then a loading function so it can come into being in stages as the row or nav link displays
struct AnchoragePotential: Mappable, Identifiable, Sendable, Equatable {
    var id: UUID { destination }
    /// This anchorage.
    /// So we know where it is, and how to navigate to more details about it
    let destination: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    var formattedAddress: String? { nil }
    let facilities: Facilities
    let rating: Double?
    let start: LocationSnippet
    let route: RouteSnippet?
    var fromLocation: CLLocationCoordinate2D?
    let distance: Double
    let duration: TimeInterval
    // I want the duration, too
    let bottom: BottomType?
    let mooringsAvailable: Bool
    let quadrantsFromStart: Set<CompassQuadrant>
    /// Based on the voyage intent - what time we'll leave, where from, how far from there to here, and average speed expected.
    /// This is the label that will be shown under the marker.
    let eta: Date
    /// Based on the voyage intent - just cached to establish a forecast range
    let etd: Date
    let darkArrival: Bool
    
    // MARK: Loading Tide
    var isLoaded: Bool = false
    /// UKC in the anchorage at the lowest tide that will occur during the time we expect to be there
    /// It would be a red flag if this is a negative amount.
    /// Requires looking up the tide table for the destination
    var minimumUKC: Double?
    /// Looking at the ETA, depth and movement of the tide.
    var tideAtArrival: TideSnapshot? // something to show as symbol on link
    /// UKC for entrance or anchorage at arrival
    var ukcAtArrival: Double?

    // MARK: Loading Weather
    /// For showing in a symbol.
    /// Filters for the marine forecasted directions during intended stay, and upgraded or downgraded based on strength of wind.
    var windExposure: CompassExposure?
    /// For showing in a symbol.
    /// Filters for the marine forecasted directions during intended stay, and upgraded or downgraded based on size of waves.
    var swellExposure: CompassExposure?
    var forecast: [ForecastSnippet] = []
    var tides: [TidePrediction] = []
    var tideStation: TideStation?
    /// Based on the tide at arrival and the entrance depth, so we know if we'll be able to get in.
    /// If we can't get in at that time, put an asterisk on the label.
}

extension AnchoragePotential {
    var label: String? { eta.formatted(.dateTime.hour().minute()) }
    static func make(from point: any Mappable) -> AnchoragePotential? {
        point as? AnchoragePotential
    }
}

extension AnchoragePotential {
    var maxGust: Double? {
        forecast.flatMap {
            $0.winds.map {
                $0.max
            }
        }.max()
    }
    var holdingScore: CompassExposure.Level? {
        if let bottom {
            switch bottom {
            case .mud, .goodHolding, .sticky: return .greenLight
            case .kelp, .soft, .grass, .clay, .sand:
                if let maxGust {
                    if maxGust <= 10 { return .greenLight }
                    else if maxGust <= 25 { return .warning }
                    else { return .danger }
                } else { return .warning }
            case .rocks, .boulders, .stones, .gravel, .pebbles, .hard, .cobbles:
                if let maxGust {
                    if maxGust <= 10 { return .greenLight }
                    else if maxGust <= 20 { return .warning }
                    else { return .danger }
                } else { return .warning}
            default:
                if let maxGust {
                    if maxGust <= 10 { return .greenLight }
                    else if maxGust <= 20 { return .warning }
                    else { return .danger }
                } else { return .warning }
            }
        } else {
            return nil
        }
    }
    var holdingSummary: String {
        var chunks: [String] = []
        if let bottom {
            chunks.append(bottom.symbol)
        }
        if let maxGust {
            chunks.append("\(maxGust.rounded) kts")
        }
        return chunks.joined(separator: " ")
    }
    func named(_ label: String? = nil) -> LocationSnippet {
        .init(name: label ?? name, latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    var colour: Color {
        guard isLoaded else { return .black }
        var levels: Set<CompassExposure.Level> = []
        
        // depth
        if let minimumUKC {
            if minimumUKC >= 1 {
                levels.insert(.greenLight)
            } else if minimumUKC >= 0 {
                levels.insert(.warning)
            } else {
                levels.insert(.redLight)
            }
        }
        if let ukcAtArrival {
            if ukcAtArrival < 1 {
                levels.insert(.warning)
            }
        }
        
        // wind exposure
        if let worst = windExposure?.worst {
            levels.insert(worst)
        }
        
        // swell exposure
        if let worst = swellExposure?.worst {
            levels.insert(worst)
        }
        
        // holding
        if mooringsAvailable {
            levels.insert(.greenLight)
        }
        else if let holdingScore {
            levels.insert(holdingScore)
        }
        
        return levels.worst?.boldColour ?? .black
    }
}
