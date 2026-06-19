//
//  PostArrivalViewModel.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import Foundation

struct PostArrivalViewModel {
    
    // manual
    var milesMadeGood: Double?
    var fathoms: Double?
    let overnightDepths: Range<Double>?
    var odometer: Int?
    var averageSpeed: Double?
    var maximumSpeed: Double?
    var fuel: FuelSounding?
    var anchorageName: String?
    var anchorageHighlights: String
    var anchorageNotes: String
    let comments: String
    
    // informational
    let passengers: String
    let duration: TimeInterval?
    let odometerStart: Int?
    let arrivalTime: Date?
    
    var trip: Trip?
}


// MARK: Extended
extension PostArrivalViewModel {
    var isCompleted: Bool {
        let mixed: [Any?] = [milesMadeGood, odometer, averageSpeed, maximumSpeed, fuel]
        guard mixed.compactMap({ $0 }).count == 5
        else { return false }
        return true
    }
    var percentComplete: Double {
        let totalPoints = 5.0
        var accumulatedPoints = 0.0
        let mixed: [Any?] = [milesMadeGood, odometer, averageSpeed, maximumSpeed, fuel]
        accumulatedPoints += mixed.compactMap({
            $0
        }).count.double
        return accumulatedPoints / totalPoints
    }
    var isEmpty: Bool {
        let mixed: [Any?] = [milesMadeGood, odometer, averageSpeed, maximumSpeed]
        guard mixed.compactMap({ $0 }).count == 0
        else { return false }
//        guard comments.isEmpty
//        else { return false }
        return true
    }
    var scope: String? {
        guard let fathoms,
              let overnightDepths
        else { return nil }
        let rodeLength = 6.0 * fathoms
        let minScope = (rodeLength / overnightDepths.upperBound).formatted(.number.precision(.fractionLength(0...1)))
        let maxScope = (rodeLength / overnightDepths.lowerBound).formatted(.number.precision(.fractionLength(0...1)))
        return "\(maxScope) | \(minScope) :1"
    }
    var depthRange: String? {
        guard let overnightDepths
        else { return nil }
        let min = overnightDepths.lowerBound.rounded.formatted(.number)
        let max = overnightDepths.upperBound.rounded.formatted(.number)
        return "\(min)-\(max) ft"
    }
    var maximumSwing: Double? {
        guard let minimumDepth = overnightDepths?.lowerBound,
              let fathoms
        else { return nil }
        // x^2 + depth^2 = rode^2
        // x^2 = rode^2 - depth^2
        let rode = 6.0 * fathoms
        guard rode > minimumDepth
        else { return nil }
        let distance = (pow(rode, 2) - pow(minimumDepth, 2)).squareRoot()
        return distance + 35.0
    }
}


// MARK: Preview
extension PostArrivalViewModel {
    static func preview(milesMadeGood: Double = .random(in: 5...25), odometer: Int = .random(in: 300...400), fuel: FuelSounding = .random) -> PostArrivalViewModel {
        .init(
            milesMadeGood: milesMadeGood,
            fathoms: 10,
            overnightDepths: 15.0..<25,
            odometer: odometer,
            averageSpeed: .random(in: 1.5...4.5),
            maximumSpeed: .random(in: 4.5...7.0),
            fuel: fuel,
            anchorageName: nil,
            anchorageHighlights: "",
            anchorageNotes: "",
            comments: .randomComments,
            passengers: .randomPassengers,
            duration: .random(in: 2.5.hour...7.hour),
            odometerStart: odometer - milesMadeGood.rounded,
            arrivalTime: .now
        )
    }
}
fileprivate extension String {
    static var randomComments: String {
        [
            "Beautiful day. Saw lots of seals. Not much wind.",
            "Foggy. But the food was good.",
            "Such a beautiful boat! Thank you for taking us out. We had such a good time.",
            "Totally enchanted. Words cannot describe!",
            "Smooth sailing. Had to motor in from Birch Point. Winds shifty above Salt Island.",
        ].randomElement()!
    }
}


// MARK: Read from trip
extension Trip {
    var postarrival: PostArrivalViewModel {
        .init(
            milesMadeGood: self.milesMadeGood,
            fathoms: self.fathoms,
            overnightDepths: self.overnightDepths,
            odometer: self.odometerEnd,
            averageSpeed: self.averageSpeed,
            maximumSpeed: self.maximumSpeed,
            fuel: self.fuelEnd ?? self.fuelStart?.copy(),
            anchorageName: self.endHarbour?.name,
            anchorageHighlights: self.endHarbour?.protectionHighlights ?? "",
            anchorageNotes: self.endHarbour?.notes ?? "",
            comments: self.comments,
            passengers: self.passengers,
            duration: self.duration,
            odometerStart: self.odometerStart,
            arrivalTime: self.arrivalTime,
            trip: self
        )
    }
}


// MARK: Write to trip
extension Trip {
    func update(postarrival: PostArrivalViewModel) {
        self.milesMadeGood = postarrival.milesMadeGood
        self.fathoms = postarrival.fathoms
        self.odometerEnd = postarrival.odometer
        self.averageSpeed = postarrival.averageSpeed
        self.maximumSpeed = postarrival.maximumSpeed
        self.fuelEnd = postarrival.fuel
        self.endHarbour?.protectionHighlights = postarrival.anchorageHighlights
        self.endHarbour?.notes = postarrival.anchorageNotes
//        self.comments = postarrival.comments
    }
    func revertPostArrival() {
        self.milesMadeGood = nil
        self.fathoms = nil
        self.odometerEnd = nil
        self.averageSpeed = nil
        self.maximumSpeed = nil
        self.fuelEnd = nil
//        self.comments = ""
    }
}
