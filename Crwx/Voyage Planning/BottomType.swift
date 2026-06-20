//
//  BottomType.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/21/25.
//

import Foundation

enum BottomType: String, CaseIterable {
    case goodHolding = "Good Holding"
    case mud, sand, rocks, boulders, clay
    case soft, hard, sticky
    case kelp, grass, oysters
    case silt, stones, gravel, pebbles, cobbles, coral, shells
    case fine, medium, coarse, broken, stiff
}

extension BottomType {
    /// My preferred symbol that makes sense to me.
    var symbol: String {
        switch self {
        case .sand:
            "Snd"
        case .mud:
            "M"
        case .rocks:
            "rky"
        case .boulders:
            "Blds"
        case .clay:
            "Cy"
        case .soft:
            "so"
        case .hard:
            "h"
        case .sticky:
            "sy"
        case .kelp:
            "Klp"
        case .grass:
            "Grs"
        case .oysters:
            "Oys"
        case .silt:
            "Si"
        case .stones:
            "St"
        case .gravel:
            "G"
        case .pebbles:
            "P"
        case .cobbles:
            "Cb"
        case .coral:
            "Co"
        case .shells:
            "Sh"
        case .fine:
            "f"
        case .medium:
            "m"
        case .coarse:
            "c"
        case .broken:
            "bk"
        case .stiff:
            "sf"
        case .goodHolding:
            "✓"
        }
    }
    /// All of the official chart symbols.
    var symbols: String {
        switch self {
        case .sand:
            "S"
        case .mud:
            "M"
        case .rocks:
            "R, Rk, rky"
        case .boulders:
            "Bo, Blds"
        case .clay:
            "Cy"
        case .soft:
            "so"
        case .hard:
            "h"
        case .sticky:
            "sy"
        case .kelp:
            "Wd, K"
        case .grass:
            "Sg, Grs"
        case .oysters:
            "Oys"
        case .silt:
            "Si"
        case .stones:
            "St"
        case .gravel:
            "G"
        case .pebbles:
            "P"
        case .cobbles:
            "Cb"
        case .coral:
            "Co"
        case .shells:
            "Sh"
        case .fine:
            "f"
        case .medium:
            "m"
        case .coarse:
            "c"
        case .broken:
            "bk"
        case .stiff:
            "sf"
        case .goodHolding:
            "-"
        }
    }
}

extension BottomType {
    var description: String {
        "\(rawValue.capitalized) (\(symbols))"
    }
}
