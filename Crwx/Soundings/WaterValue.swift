//
//  WaterValue.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import Foundation

/// Because my water tank level sensor measures ranges of values.
enum WaterValue: Double, CaseIterable {
    case seventyThree = 0.865
    case sixtySix = 0.695
    case sixtyOne = 0.635
    case fiftyFour = 0.575
    case fortySix = 0.5
    case fortyOne = 0.435
    case thirtyFour = 0.375
    case thirty = 0.32
    case twentyFive = 0.275
    case twentyOne = 0.23
    case eighteen = 0.195
    case fourteen = 0.16
    case eleven = 0.125
    case nine = 0.1
    case five = 0.07
    case four = 0.045
    case two = 0.03
    case zero = 0.01
}

extension WaterValue: CustomStringConvertible {
    var gallons: String {
        switch self {
        case .seventyThree:
            "31-42 gals"
        case .sixtySix:
            "28-31 gals"
        case .sixtyOne:
            "26-28 gals"
        case .fiftyFour:
            "23-26 gals"
        case .fortySix:
            "19-23 gals"
        case .fortyOne:
            "17-19 gals"
        case .thirtyFour:
            "14-17 gals"
        case .thirty:
            "13-14 gals"
        case .twentyFive:
            "11-13 gals"
        case .twentyOne:
            "9-11 gals"
        case .eighteen:
            "8-9 gals"
        case .fourteen:
            "6-8 gals"
        case .eleven:
            "5-6 gals"
        case .nine:
            "4-5 gals"
        case .five:
            "2-4 gals"
        case .four:
            "2 gals"
        case .two:
            "1-2 gals"
        case .zero:
            "0-1 gals"
        }
    }
    var percent: String {
        switch self {
        case .seventyThree:
            "73-100%"
        case .sixtySix:
            "66-73%"
        case .sixtyOne:
            "61-66%"
        case .fiftyFour:
            "54-61%"
        case .fortySix:
            "46-54%"
        case .fortyOne:
            "41-46%"
        case .thirtyFour:
            "34-41%"
        case .thirty:
            "30-34%"
        case .twentyFive:
            "25-30%"
        case .twentyOne:
            "21-25%"
        case .eighteen:
            "18-21%"
        case .fourteen:
            "14-18%"
        case .eleven:
            "11-14%"
        case .nine:
            "9-11%"
        case .five:
            "5-9%"
        case .four:
            "4-5%"
        case .two:
            "2-4%"
        case .zero:
            "0-2%"
        }
    }
    var description: String {
        "\(gallons)  \(percent)"
    }
}
