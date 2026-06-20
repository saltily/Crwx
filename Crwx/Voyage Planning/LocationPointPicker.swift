//
//  LocationPointPicker.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 9/14/23.
//

import SwiftUI
import CoreLocation
import FoundationSalt
import WxSalt
import FoundationUI

public struct LocationPointPicker: View {
    public init(point: Binding<CLLocation>, completion: @escaping (String) -> Void = ({ _ in })) {
        self._point = point
        self.completion = completion
    }
    @Binding var point: CLLocation
    private var completion: (String) -> Void
    public var body: some View {
        NavigationLink(destination: LocationPointMapView(selection: $point)) {
            PointText(point) { placemark in
                completion(placemark)
            }
            .relativeBadge(point)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            InteractivePreview()
        }
    }
    .locationManager()
    .preferredColorScheme(.dark)
}
fileprivate struct InteractivePreview: View {
    @State private var point: CLLocation = .default
    var body: some View {
        LocationPointPicker(point: $point)
    }
}
