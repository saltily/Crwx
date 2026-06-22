//
//  TrackDot.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/10/25.
//

import SwiftUI
import MapKit
import FoundationSalt
import FoundationUI
import WxSalt

struct TrackDot: MapContent {
    init(_ point: any Mappable, tint: Color = .night(.green)) {
        self.point = point
        self.tint = tint
    }
    let point: any Mappable
    let tint: Color
    var body: some MapContent {
        MapDot(point, tint: tint, width: 5, border: 1)
    }
}
extension MapBasket {
    func trackDot(_ point: any Mappable, tint: Color = .night(.green)) {
        self.dot(point, tint: tint, width: 5, border: 1)
    }
    func dot(snippet: WaypointSnippet) {
        if snippet.isHarbour {
            self.dot(snippet, tint: .red)
        } else if snippet.isHub {
            self.dot(snippet, tint: .green)
        } else {
            self.trackDot(snippet)
        }
    }
}
extension MapDot {
    init(snippet: WaypointSnippet) {
        if snippet.isHarbour {
            self.init(snippet, tint: .red)
        } else if snippet.isHub {
            self.init(snippet, tint: .green)
        } else {
            self.init(snippet, tint: .night(.green), width: 5, border: 1)
        }
    }
}
