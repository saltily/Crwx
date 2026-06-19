//
//  ForecastSnippet.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation
import FoundationSalt
import WeatherKit
import WxSalt

struct ForecastSnippet: Codable, Equatable {
    var date: Date
    var _point: LocationSnippet
    var _zone: MarineZoneSnippet
    
    // conditions
    var symbolName: String = ""
    var highTemperature: Double?
    
    // wind
    var winds: [WindSnippet] = []
    
    // waves
    var waves: [WaveSnippet] = []
    var lowWaveFeet: Int?
    var highWaveFeet: Int?
    
    // text
    var text: String = ""
    
    init(date: Date, point: LocationSnippet = .zero, zone: MarineZoneSnippet = .zero, symbolName: String = "", highTemperature: Double? = nil, winds: [WindSnippet], lowWaveFeet: Int? = nil, highWaveFeet: Int? = nil, text: String = "") {
        self.date = date
        self._point = point
        self._zone = zone
        self.symbolName = symbolName
        self.highTemperature = highTemperature
        self.winds = winds
        self.lowWaveFeet = lowWaveFeet
        self.highWaveFeet = highWaveFeet
        self.text = text
    }
    
}

// MARK: Locations
extension ForecastSnippet {
    var point: LocationSnippet? {
        get {
            _point.isEmpty ? nil : _point
        }
        set {
            if let newValue {
                _point = newValue
            } else {
                _point = .zero
            }
        }
    }
    var zone: MarineZoneSnippet? {
        get {
            _zone.isEmpty ? nil : _zone
        }
        set {
            if let newValue {
                _zone = newValue
            } else {
                _zone = .zero
            }
        }
    }
    static var zero: ForecastSnippet {
        .init(date: .distantPast, winds: [])
    }
    var isEmpty: Bool {
        self.date == .distantPast
    }
    var hasSomething: Bool {
        !(self.winds.isEmpty && text.isEmpty && highTemperature == nil && lowWaveFeet == nil && highWaveFeet == nil)
    }
}

// MARK: Extended
extension ForecastSnippet {
    var wavesSummary: String {
        let heights = [lowWaveFeet, highWaveFeet].compactMap { $0 }
        if heights.count == 0 { return "" }
        else if heights.count == 1 { return "\(heights[0]) ft" }
        let low = heights[0]
        let high = heights[1]
        if low == high { return "\(low) ft" }
        return "\(low)-\(high) ft"
    }
    init(zone: MarineZone, wx: MarineZoneWeather, date: Date) {
        self.date = date
        self.text = wx.summary
        self._point = .zero
        self._zone = zone.snippet
        self.parseMarineText()
    }
    init(apple: DayWeather?, noaa: NoaaHalfDayWeather?, date: Date, point: LocationSnippet) {
        self.date = date
        self.symbolName = apple?.symbolName ?? ""
        self.highTemperature = apple?.highTemperature.converted(to: .fahrenheit).value
        if let wind = apple?.wind {
            self.winds = [
                .init(apple: wind)
            ]
        }
        self.text = noaa?.summary ?? ""
        self._point = point
        self._zone = .zero
    }
    init(hours: [HourWeather], zone: MarineZone, date: Date) {
        self.date = date
        self._point = .zero
        self._zone = zone.snippet
        // symbol
        self.symbolName = hours.symbolName
        // high temperature
        self.highTemperature = hours.highTemperature
        // winds
        self.winds = hours.winds
        // waves
        // text
    }
    var isMarine: Bool {
        zone != nil
    }
}


// MARK: Preview
extension ForecastSnippet {
    static func random(_ isMarine: Bool = false, before date: Date = .now, point: LocationSnippet?) -> ForecastSnippet {
        let lowWaves: Int?
        let highWaves: Int?
        if isMarine {
            lowWaves = Int.random(in: 0...4)
            let waveRange = [0,1,2,2,2,2,2,2,2,3].randomElement()!
            highWaves = lowWaves! + waveRange
        }
        else {
            lowWaves = nil
            highWaves = nil
        }
        return ForecastSnippet(
            date: date,
            point: point ?? .random,
            zone: .random,
            symbolName: .randomWeatherSymbolName,
            highTemperature: .random(in: 55...80),
            winds: .random,
            lowWaveFeet: lowWaves,
            highWaveFeet: highWaves,
            text: .wxForecastSynopsis(isMarine: isMarine)
        )
    }
}
fileprivate extension String {
    static var randomWeatherSymbolName: String {
        WxSymbol.wxCases.randomElement()!.rawValue
    }
    static func wxForecastSynopsis(isMarine: Bool) -> String {
        isMarine ? sampleMarineSynopsis.randomElement()! : sampleLocalSynopsis.randomElement()!
    }
    static var sampleLocalSynopsis: [String] {
        [
            """
Rain showers likely before 5pm, then rain likely, possibly mixed with snow showers. Cloudy, with a high near 40. Northeast wind 11 to 13 mph, with gusts as high as 23 mph. Chance of precipitation is 60%. Total daytime snow accumulation of less than a half inch possible.
""",
            """
Sunny, with a high near 55. Northwest wind 5 to 7 mph.
""",
            """
Sunny, with a high near 44. North wind 11 to 14 mph, with gusts as high as 24 mph.
""",
            """
Partly cloudy, with a high near 46. North wind around 6 mph.
""",
            """
A chance of rain. Mostly cloudy, with a high near 45. South wind 6 to 9 mph. Chance of precipitation is 40%.
"""
        ]
    }
    static var sampleMarineSynopsis: [String] {
        [
            """
NE winds 15 to 20 kt, increasing to 20 to 25 kt late. Seas 5 to 6 ft. Numerous showers. Vsby 1 to 3 NM late this morning.
""",
            """
N winds 20 to 25 kt, diminishing to 15 to 20 kt in the afternoon. A few gusts up to 35 kt. Seas 4 to 6 ft. Scattered rain and snow showers in the morning.
""",
            """
NW winds 10 to 15 kt, becoming W in the afternoon. Seas 2 to 4 ft.
""",
            """
N winds 10 to 15 kt, becoming NE 5 to 10 kt. Seas around 2 ft, then 1 foot or less.
""",
            """
NE winds 5 to 10 kt, becoming S. Seas 1 foot or less, then around 2 ft.
""",
        ]
    }
}



// MARK: Lumping Together Apple Hourly
fileprivate extension [HourWeather] {
    // symbol
    // high temperature
    // winds
    // waves - none
    // text - none
    var symbolName: String {
        self.map { $0.symbolName }.countedSet.max() ?? ""
    }
    var highTemperature: Double? {
        self.map { $0.temperature.converted(to: .fahrenheit).value }.max()
    }
    /// Grouping the hours by shifts that change the cardinal and discarding any directions that didn't stick around for more than two hours
    /// Typically used when trying to turn 12 hours of wind into something that would resemble a marine zone forecast
    var winds: [WindSnippet] {
        let winds = self.map { $0.wind }
        guard !winds.isEmpty else { return [] }
        var reader = winds.reader
        var currentCardinal = reader.currentItem.direction.cardinalDirection
        var snippets = [(WindSnippet, Int)]()
        var minSpeed = self[0].wind.speed.converted(to: .knots).value
        var maxSpeed = minSpeed
        var maxGust = 0.0
        var hourCount = 0
        while !reader.didReachEnd {
            let wind = reader.read()
            let cardinal = wind.direction.cardinalDirection
            let speed = wind.speed.converted(to: .knots).value
            let gust = wind.gust?.converted(to: .knots).value ?? 0
            if cardinal == currentCardinal {
                minSpeed = Swift.min(minSpeed, speed)
                maxSpeed = Swift.max(maxSpeed, speed)
                maxGust = Swift.max(maxGust, gust)
                hourCount += 1
            } else {
                snippets.append((.init(direction: currentCardinal.direction?.converted(to: .degrees).value, gust: maxGust.nilIfZero, speed: minSpeed..<maxSpeed), hourCount))
                currentCardinal = cardinal
                minSpeed = speed
                maxSpeed = speed
                maxGust = gust
                hourCount = 1
            }
        }
        snippets.append((.init(direction: currentCardinal.direction?.converted(to: .degrees).value, gust: maxGust.nilIfZero, speed: minSpeed..<maxSpeed), hourCount))
        if self.count > 2 {
            snippets = snippets.filter { snippet, ct in
                ct > 2
            }
        }
        let result = snippets.map { snippet, _ in
            snippet
        }
//        let hourSummary = self.map {
//            WindSnippet(apple: $0.wind).summary
//        }.joined(separator: ", ")
//        let hour = self.first?.date.formatted(.dateTime.hour().minute().weekday().day()) ?? "?:??"
//        logger.trace("\(hour) - Combined winds is \(result.summary) from \(hourSummary)")
        return result
    }
}



// MARK: Parse Marine Zone Text
extension ForecastSnippet {
    private mutating func parseMarineText() {
        // find wind direction
        // find wind speed range
        // find wind gusts
        parseMarineWind()
        // find wave range
        parseMarineWaves()
    }
    private mutating func parseMarineWind() {
        // NE winds 15 to 20 kt, increasing to 20 to 25 kt late.
        // NE winds 20 to 25 kt with a few gusts up to 35 kt.
        // N winds 20 to 25 kt, diminishing to 15 to 20 kt in the afternoon. A few gusts up to 35 kt.
        // N winds 15 to 20 kt, diminishing to 10 to 15 kt after midnight. Gusts up to 30 kt.
        // NW winds 10 to 15 kt, becoming W in the afternoon.
        // W winds 10 to 15 kt, becoming NW after midnight. Gusts up to 25 kt.
        // N winds 10 to 15 kt, becoming NE 5 to 10 kt.
        // NE winds 5 to 10 kt, becoming S.
        // NW winds around 10 kt, becoming W in the afternoon.
        // NE winds 20 to 25 kt with gusts up to 30 kt.
        // W winds around 15 kt, becoming NW after midnight.
        // E winds around 10 kt, becoming S.
        // N winds 15 to 20 kt with gusts up to 30 kt, diminishing to 10 to 15 kt late this evening and overnight.
        
        // Note first half always direction and one or two speeds
        // Note sometimes a second wind
        // 2nd wind sometimes only direction, sometimes only speed
        // Sometimes gust, only ever one gust
        // Gust sometimes same sentence, sometimes second sentence
        
        // Gust always like 'usts up to \d kt
        var gust: [Double] = []
        if let gustSentence = self.text.firstMatch(of: /[Gg](usts up to )\d+( kt)/) {
            if let gustSpeed = gustSentence.0.firstMatch(of: /\d+/) {
                if let g = Double(gustSpeed.0) {
                    gust.append(g)
                }
            }
        }

        // Winds would be sentence starting with direction and 'winds' and going to either 'gust' or '.'
        var directions: [String] = []
        var speeds: [[Double]] = []
        if let windsSentence = self.text.firstMatch(of: /[NESW]{1,2}( winds)[^\.]+/) {
            directions = windsSentence.0.matches(of: /[NESW]{1,2}( )/).map {
                $0.0.trimmingCharacters(in: .whitespaces)
            }
            let speedPhrases = windsSentence.0.matches(of: /(\d+ to )?\d+( kt)/).map {
                $0.0
            }
            speeds = speedPhrases.map {
                $0.matches(of: /\d+/).compactMap {
                    Double($0.0)
                }
            }.filter {
                $0 != gust
            }
        }
        
        // one or two winds
        let windCount = max(directions.count, speeds.count)
        if windCount == 1 {
            if let directionString = directions.first,
               let compass = try? CompassDirection(string: directionString),
               let speeds = speeds.first
            {
                self.winds = [
                    .init(direction: compass.direction?.converted(to: .degrees).value, speed: speeds, gust: gust.first)
                ]
            }
        }
        else if windCount == 2 {
            let firstWind: WindSnippet? =
            if let directionString = directions.first,
               let compass = try? CompassDirection(string: directionString),
               let speeds = speeds.first
            {
                .init(direction: compass.direction?.converted(to: .degrees).value, speed: speeds)
            } else { nil }
            let secondWind: WindSnippet? =
            if let directionString = directions.last,
               let compass = try? CompassDirection(string: directionString),
               let speeds = speeds.last
            {
                .init(direction: compass.direction?.converted(to: .degrees).value, speed: speeds)
            } else { nil }
            let winds = [firstWind, secondWind].compactMap { $0 }
            if let gust = gust.first {
                if winds.count == 1 {
                    var wind = winds[0]
                    wind.gust = gust
                    self.winds = [wind]
                }
                else if winds.count == 2 {
                    if (winds[0].speed.upperBound >= winds[1].speed.upperBound) {
                        var wind = winds[0]
                        wind.gust = gust
                        self.winds = [
                            wind,
                            winds[1]
                        ]
                    }
                    else {
                        var wind = winds[1]
                        wind.gust = gust
                        self.winds = [
                            winds[0],
                            wind
                        ]
                    }
                }
            }
            else {
                self.winds = winds
            }
        }
    }
    private mutating func parseMarineWaves() {
        // Seas 3 to 5 ft
        // Seas around 2 ft, then 1 foot or less
        // Seas 1 foot or less, then around 2 ft
        
        // find a sentence from 'Seas' to '. '
        if let sentence = self.text.firstMatch(of: /(Seas)[^\.]+/) {
            // extract the two integers and put them in order
            let integers = sentence.0.matches(of: /\d+/).compactMap {
                Int($0.0)
            }.sorted()
            self.lowWaveFeet = integers.first
            self.highWaveFeet = integers.last
        }
        
        // find wave detail sentance
        if let sentence = self.text.firstMatch(of: /(Wave Detail\:)[^\.]+/) {
            let pieces = sentence.0.matches(of: /[NSEW]{1,2}\s\d+( f)(oo)?(t at )\d+/)
            self.waves = pieces.compactMap {
                let compass = $0.0.matches(of: /[NSEW]{1,2}/).first
                let doubles = $0.0.matches(of: /\d+/).compactMap {
                    Double($0.0)
                }
                guard doubles.count == 2,
                      let compass,
                      let cd = try? CompassDirection(string: compass.0.string)
                else { return nil }
                return .init(
                    direction: cd.direction?.converted(to: .degrees).value,
                    height: doubles[0],
                    period: doubles[1]
                )
            }
        }
    }
}



// MARK: Fetching Local Wx
extension ForecastSnippet {
    func updating(with forecast: ForecastSnippet?) -> ForecastSnippet {
        var copy = self
        copy.update(with: forecast)
        return copy
    }
    mutating func update(with forecast: ForecastSnippet?) {
        if let forecast {
            // if the day of the forecast changed, replace everything
            if forecast.date.withoutTime != self.date.withoutTime {
                self = forecast
            }
            // if switch between marine and local, replace everything
            else if forecast.isMarine != self.isMarine {
                self = forecast
            }
            // else you can replace individual but don't unset anything
            else {
                if !forecast.symbolName.isEmpty {
                    self.symbolName = forecast.symbolName
                }
                if let value = forecast.highTemperature {
                    self.highTemperature = value
                }
                if let value = forecast.highWaveFeet {
                    self.highWaveFeet = value
                }
                if let value = forecast.lowWaveFeet {
                    self.lowWaveFeet = value
                }
                if let value = forecast.point {
                    self.point = value
                }
                if let value = forecast.zone {
                    self.zone = value
                }
                if !forecast.winds.isEmpty {
                    self.winds = forecast.winds
                }
                if !forecast.text.isEmpty {
                    self.text = forecast.text
                }
                self.date = forecast.date
            }
        }
    }
    static func fetchLocal(for point: any Mappable, at date: Date) async throws -> ForecastSnippet {
        // first let's name the location if it isn't named
        let loc: LocationSnippet? = .make(from: point)
        guard var loc else { throw "Could not resolve location for local forecast" }
        if loc.name == nil {
            try await loc.fetchName()
        }
        
        // now let's get the apple daily forecast
        let appleWx: DayWeather? = try await Retry.do(3) {
            let wx: Forecast<DayWeather>
            if (0..<10.day).contains(date.timeIntervalSince(.now.withoutTime)) {
                wx = try await WeatherService().weather(for: loc.clLocation).dailyForecast
            }
            else {
                // pull up history
                wx = try await AppleHistoryWxService().weather(for: loc.clLocation, from: date.addingTimeInterval(-2.day), to: date.addingTimeInterval(2.day)).daily
            }
            return wx.first {
                $0.date.withoutTime == date.withoutTime
            }
        }
        
        // and let's get the noaa forecast
        let noaaWx: NoaaHalfDayWeather? = try await Retry.do(5) {
            if (0..<6.day).contains(date.timeIntervalSince(.now.withoutTime)) {
                // look for it in the forecast
                let wx = try await NoaaDailyWxService().weather(for: loc.clLocation)
                return wx.first {
                    $0.date.withoutTime == date.withoutTime
                }
            }
            else {
                return nil // too old to find anything
            }
        }

        return .init(apple: appleWx, noaa: noaaWx, date: date, point: loc)
    }
}

//// MARK: Codable
extension ForecastSnippet {
    enum CodingKeys: CodingKey {
        case date, _point, _zone, symbolName, highTemperature, winds, lowWaveFeet, highWaveFeet, text
    }
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        _point = try container.decode(LocationSnippet.self, forKey: ._point)
        _zone = try container.decode(MarineZoneSnippet.self, forKey: ._zone)
        symbolName = try container.decode(String.self, forKey: .symbolName)
        highTemperature = try container.decodeIfPresent(Double.self, forKey: .highTemperature)
        winds = try container.decode([WindSnippet].self, forKey: .winds)
        lowWaveFeet = try container.decodeIfPresent(Int.self, forKey: .lowWaveFeet)
        highWaveFeet = try container.decodeIfPresent(Int.self, forKey: .highWaveFeet)
        text = try container.decode(String.self, forKey: .text)
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(_point, forKey: ._point)
        try container.encode(_zone, forKey: ._zone)
        try container.encode(symbolName, forKey: .symbolName)
        try container.encodeIfPresent(highTemperature, forKey: .highTemperature)
        try container.encode(winds, forKey: .winds)
        try container.encodeIfPresent(lowWaveFeet, forKey: .lowWaveFeet)
        try container.encodeIfPresent(highWaveFeet, forKey: .highWaveFeet)
        try container.encode(text, forKey: .text)
    }
}
