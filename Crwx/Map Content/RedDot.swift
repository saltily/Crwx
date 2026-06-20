//
//  RedDot.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 11/30/23.
//

import SwiftUI
import MapKit
import FoundationSalt

struct RedDot: MapContent {
    let point: any Mappable
    var body: some MapContent {
        Annotation(point.label ?? "", coordinate: point.coordinate) {
            Circle()
                .fill(.white)
                .frame(width: 14)
                .shadow(radius: 5)
                .overlay {
                    Circle()
                        .fill(.red)
                        .frame(width: 10)
                }
        }
    }
}

#Preview {
    Map {
        RedDot(point: CLLocation.default)
    }
}
