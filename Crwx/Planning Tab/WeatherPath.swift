//
//  WeatherPath.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import Foundation
import WxSalt

enum WeatherPath {
    case marineWeather, tides, currents, seaBuoy, radar
}

extension WeatherPath {
    var label: String {
        switch self {
        case .marineWeather:
            "Marine Forecast"
        case .tides:
            "Tides"
        case .currents:
            "Tidal Currents"
        case .seaBuoy:
            "Sea Buoy"
        case .radar:
            "Radar"
        }
    }
    var systemImage: String {
        switch self {
        case .marineWeather:
            "text.page"
        case .tides:
            WeatherAngle.tide.symbolName
        case .currents:
            WeatherSource.tidalCurrents.symbolName
        case .seaBuoy:
            WeatherSource.marineBuoy.symbolName
        case .radar:
            "antenna.radiowaves.left.and.right"
        }
    }
}
