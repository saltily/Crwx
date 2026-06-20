//
//  AddHarbourPointPicker.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/25/25.
//

import SwiftUI
import SwiftData
import FoundationUI
import MapKit

struct AddHarbourPointPicker: View {
    init(region: MKCoordinateRegion, isPresented: Binding<Bool>) {
        self.launchRegion = region
        _region = .init(initialValue: region)
        self._isPresented = isPresented
    }
    private let launchRegion: MKCoordinateRegion
    @State private var region: MKCoordinateRegion
    @Binding private var isPresented: Bool
    @Query private var harbours: [Harbour]
    var body: some View {
        ZStack {
            SafeChartMap(region: $region) {
                ForEach(harbours) { harbour in
                    MapDot(harbour, defaultTint: .black)
                }
            } legacy: { map in
                for harbour in harbours {
                    map.dot(harbour, defaultTint: .black)
                }
            }
            .northUp()
            HStack(spacing: 10) {
                Text(region.center.latitude, format: .latitude.minutes(.fractionLength(2)).compass())
                Text(region.center.longitude, format: .longitude.minutes(.fractionLength(2)).compass().degrees(.wide))
            }
            .foregroundStyle(.black)
            .mapAlignment(.bottom)
            NavigationLink(destination: AddHarbourDetail(coordinate: region.center, isPresented: $isPresented)) {
                Image(systemName: "scope")
                    .font(.title2)
            }
        }
        .onChange(of: launchRegion) { oldValue, newValue in
            if region != newValue {
                region = newValue
            }
        }
    }
}

#Preview {
    AddHarbourPointPicker(region: .MaineCoast, isPresented: .constant(true))
}

fileprivate struct AddHarbourDetail: View {
    let coordinate: CLLocationCoordinate2D
    @Binding var isPresented: Bool
    @State private var new: Harbour?
    @Environment(\.modelContext) private var context
    var body: some View {
        Group {
            if let new {
                HarbourDetail(harbour: new)
            } else {
                List {
                    ProgressView()
                        .seaSection()
                }
            }
        }
        .seaBackground()
        .navigationTitle(new?.name ?? "New Harbour")
        .toolbar {
            Button("Done") {
                isPresented = false
            }
            .fontWeight(.bold)
        }
        .task {
            let vm = await HarbourViewModel(coordinate: coordinate)
            let container = context.container
            let task = Task.detached {
                let actor = BackModelActor(modelContainer: container)
                return try await actor.save(harbour: vm)
            }
            do {
                let pid = try await task.value
                guard let harbour = context.model(for: pid) as? Harbour
                else { throw BackModelActor.E.BadId }
                self.new = harbour
            } catch {
                logger.critical("Couldn't create new harbour: \(error)")
            }
        }
    }
}
