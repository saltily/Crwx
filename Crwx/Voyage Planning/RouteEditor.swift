//
//  RouteEditor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/17/25.
//

import SwiftUI
import MapKit
import FoundationUI
import FoundationSalt

struct RouteEditor: View {
    var initialCentre: CLLocationCoordinate2D?
    var startingPoint: RouteSnippet?
    @Environment(\.modelContext) private var context
    @CoastRegion private var coastalRegion
    var body: some View {
        NestOne(route: .init(modelContext: context, snippet: startingPoint), centreOn: initialCentre, coastalRegion: coastalRegion)
    }
}
fileprivate struct NestOne: View {
    init(route: RouteMaker, centreOn: CLLocationCoordinate2D? = nil, coastalRegion: CoastalRegion?) {
        _route = .init(initialValue: route)
        let region: MKCoordinateRegion =
        if let centreOn {
            .init(center: centreOn, diameter: .init(value: 0.5, unit: .nauticalMiles))
        }
        else if route.points.count > 1 {
            .fitting(points: route.points)
        }
        else {
            .fitting(points: route.allWaypoints.coastalRegion(coastalRegion))
        }
        _region = .init(initialValue: region)
    }
    @State var route: RouteMaker
    @State private var region: MKCoordinateRegion
    @State private var confirmSave = false
    var body: some View {
        ZStack {
            SafeChartMap(region: $region) {
                RouteEditor.MapBody(route: route, region: region)
            } legacy: { map in
                RouteEditor.draw(map, route: route, region: region)
            }
            RouteEditor.ActionButton(route: route, region: region, canAct: route.canAct(in: region))
            RouteEditor.OverlayControls(route: route)
        }
        .safeAreaInset(edge: .bottom) {
            Text(route.description)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(.thinMaterial)
        }
        .navigationTitle(route.name)
        .toolbarTitleDisplayMode(.inline)
        .saveButton(disabled: !route.canSave) {
            confirmSave = true
            return false
        }
        .task {
            // it seems important that this not be called too early, else I think the task takes an instance of the maker that is not the one that is owned here by the view
            await route.updateEnds()
        }
        .alert("Saving Route", isPresented: $confirmSave) {
            DismissButton("Route is Safe") {
                route.save(isReviewed: true)
            }
            .tint(.blue)
            .fontWeight(.bold)
            DismissButton("Route Needs Review") {
                route.save(isReviewed: false)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Has this route been reviewed for safe navigation?")
        }

    }
}
extension WaypointSnippet {
    func display(in region: MKCoordinateRegion) -> Bool {
        if isMajor || region.span.longitudeDelta < 0.5 {
            return region.contains(self)
        }
        return false
    }
    var isMajor: Bool {
        isHub || isHarbour
    }
}
extension Marker where Label == Text? {
    init(_ point: any Mappable) {
        self.init(coordinate: point.coordinate) {
            if let label = point.label {
                Text(label)
            }
        }
    }
}
struct AddRouteButton: View {
    var body: some View {
        NavigationLink(destination: RouteEditor()) {
            Label("Add Route", systemImage: "pencil.and.scribble")
        }
    }
}
