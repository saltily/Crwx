//
//  ObservationSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import FoundationSalt
import WxSalt

struct ObservationSnippet: Codable, Equatable {
    let date: Date
    var buoy: MarineBuoySnippet? // make !
    let airTemperature: Double?
    let waterTemperature: Double?
    var windDirection: Double?
    var windSpeed: Double?
    var gust: Double?
    var waveHeight: Double?
    var wavePeriod: TimeInterval?
    let averageWavePeriod: TimeInterval?
    let waveDirection: Double?
}

// MARK: Extended
extension ObservationSnippet {
    var windAngle: Measurement<UnitAngle>? {
        guard let direction = windDirection
        else { return nil }
        return .init(value: direction, unit: .degrees)
    }
    var compassDirection: CompassDirection {
        .init(cardinal: windAngle)
    }
    var period: TimeInterval? {
        wavePeriod ?? averageWavePeriod
    }
}


// MARK: Preview
extension ObservationSnippet {
    static func random(before: Date = .now) -> ObservationSnippet {
        let timeBefore = TimeInterval.random(in: (-35)...(-12))
        let windSpeed = Double.random(in: 0...30)
        let windDifferential = Double.random(in: 0...7)
        return ObservationSnippet(
            date: before.addingTimeInterval(timeBefore),
            buoy: .random,
            airTemperature: .random(in: 50...65),
            waterTemperature: .random(in: 45...58),
            windDirection: .random(in: 0...360),
            windSpeed: windSpeed,
            gust: windSpeed + windDifferential,
            waveHeight: .random(in: 1...7),
            wavePeriod: .random(in: 6...10),
            averageWavePeriod: nil,
            waveDirection: .random(in: 100...250)
        )
    }
}


// MARK: Make from marine buoy observation
extension BuoyObservation {
    func snippet(buoy: MarineBuoy) -> ObservationSnippet {
        .init(
            date: self.date,
            buoy: buoy.snippet,
            airTemperature: self.airTemperature?.converted(to: .fahrenheit).value,
            waterTemperature: self.waterTemperature?.converted(to: .fahrenheit).value,
            windDirection: self.windDirection?.converted(to: .degrees).value,
            windSpeed: self.windSpeed?.converted(to: .knots).value,
            gust: self.gust?.converted(to: .knots).value,
            waveHeight: self.waveHeight?.converted(to: .feet).value,
            wavePeriod: self.wavePeriod,
            averageWavePeriod: self.averageWavePeriod,
            waveDirection: self.waveDirection?.converted(to: .degrees).value
        )
    }
}

// MARK: Codable
extension ObservationSnippet {
    enum CodingKeys: CodingKey {
        case date, buoy, airTemperature, waterTemperature, windDirection, windSpeed, gust, waveHeight, wavePeriod, averageWavePeriod, waveDirection
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        buoy = try container.decodeIfPresent(MarineBuoySnippet.self, forKey: .buoy)
        airTemperature = try container.decodeIfPresent(Double.self, forKey: .airTemperature)
        waterTemperature = try container.decodeIfPresent(Double.self, forKey: .waterTemperature)
        windDirection = try container.decodeIfPresent(Double.self, forKey: .windDirection)
        windSpeed = try container.decodeIfPresent(Double.self, forKey: .windSpeed)
        gust = try container.decodeIfPresent(Double.self, forKey: .gust)
        waveHeight = try container.decodeIfPresent(Double.self, forKey: .waveHeight)
        wavePeriod = try container.decodeIfPresent(TimeInterval.self, forKey: .wavePeriod)
        averageWavePeriod = try container.decodeIfPresent(TimeInterval.self, forKey: .averageWavePeriod)
        waveDirection = try container.decodeIfPresent(Double.self, forKey: .waveDirection)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(buoy, forKey: .buoy)
        try container.encodeIfPresent(airTemperature, forKey: .airTemperature)
        try container.encodeIfPresent(waterTemperature, forKey: .waterTemperature)
        try container.encodeIfPresent(windDirection, forKey: .windDirection)
        try container.encodeIfPresent(windSpeed, forKey: .windSpeed)
        try container.encodeIfPresent(gust, forKey: .gust)
        try container.encodeIfPresent(waveHeight, forKey: .waveHeight)
        try container.encodeIfPresent(wavePeriod, forKey: .wavePeriod)
        try container.encodeIfPresent(averageWavePeriod, forKey: .averageWavePeriod)
        try container.encodeIfPresent(waveDirection, forKey: .waveDirection)
    }
}
