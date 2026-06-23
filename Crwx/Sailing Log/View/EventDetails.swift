//
//  EventDetails.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/11/24.
//

import SwiftUI
import MapKit
import FoundationSalt
import WxSalt

struct EventDetails: View {
    @Binding var event: VoyageEvent
    @State private var mapCamera: MapCameraPosition = .automatic
    @State private var editEvent: VoyageEvent?
    var body: some View {
        List {
            Group {
                // text
                Section {
                    Text(event.text)
//                    TextField("Body", text: $event.text, axis: .vertical)
//                        .lineLimit(5...)
//                        .frame(minHeight: 120, alignment: .leading)
                } header: {
                    if event.time.isToday {
                        Text("Today")
                    } else if event.time.isYesterday {
                        Text("Yesterday")
                    } else {
                        Text(event.time, format: .dateTime.month(.wide).day().year())
                    }
                }
                // location
                if let location = event.location {
                    Section {
                        Map(position: $mapCamera) {
                            Marker("", coordinate: location.coordinate)
                        }
                        .frame(height: 200)
                    } header: {
                        Text("Location")
                    } footer: {
                        Text(location.coordinate, format: .location.minutes().precision(.fractionLength(2)))
                    }
                    .onAppear {
                        centreMap(on: location.coordinate)
                    }
                }
            }
            .seaSection()
        }
        .listStyle(.grouped)
        .seaBackground(.flat)
        .navigationTitle(Text(event.time, format: .dateTime.hour().minute()))
        .toolbar {
            Button("Edit", systemImage: "pencil") {
                editEvent = event
            }
        }
        .editEvent($editEvent, label: "Edit Event") { event in
            self.event = event
        }
    }
    private func centreMap(on point: CLLocationCoordinate2D?) {
        if let point {
            mapCamera = .region(.init(center: point, diameter: .init(value: 1.5, unit: .nauticalMiles)))
        }
    }

}

#Preview {
    NavigationStack {
        EventDetails(event: .constant(.random))
    }
    .preferredColorScheme(.dark)
}
