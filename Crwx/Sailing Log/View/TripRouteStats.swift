//
//  TripRouteStats.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/10/25.
//

import SwiftUI

struct TripRouteStats: View {
    @Bindable var model: TripRouteForm.LiveRoute
    var body: some View {
        if let length = model.length,
           let bearing = model.bearing,
           let route = model.route
        {
            NavigationLink(destination: RouteInspector(route: route)) {
                HStack {
                    Text("Stats")
                    Spacer()
                    Text(model.count, format: .number) + Text(" legs, ") +
                    Text(length, format: .number.precision(.fractionLength(0...1))) + Text(" nm")
                    Image(systemName: "location.north.fill")
                        .rotationEffect(.degrees(bearing.converted(to: .degrees).value))
                        .frame(height: 20)
                }
            }
        }
    }
}
