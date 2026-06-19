//
//  VoyageeventEditorRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import CoreLocation
import FoundationSalt

struct VoyageeventEditorRow: View {
    @Binding var event: VoyageEvent?
    @State private var mutable: VoyageEvent = .init()
    @PositionTracker private var tracker
    @FocusState private var textIsFocused: Bool
    var body: some View {
        if let _ = event {
            VStack(alignment: .leading, spacing: 8) {
                DatePicker("Time", selection: $mutable.time, displayedComponents: [.date, .hourAndMinute])
                TextField("Description", text: $mutable.text, axis: .vertical)
                    .lineLimit(3...)
                    .focused($textIsFocused)
            }
            .padding(.vertical, 5)
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button(systemImage: "arrow.clockwise") {
                    Task {
                        mutable.time = .now
                        let loc: CLLocation? = await tracker.currentLocation // ?? .randomOnCoastOfMaine()
                        mutable.location = loc?.coordinate.codable
                    }
                }
                .tint(.accentColor)
            }
            .onAppear {
                mutable = event ?? .init()
                textIsFocused = true
            }
            .onChange(of: mutable) { oldValue, newValue in
                if newValue != event {
                    event = mutable
                }
            }
            .onChange(of: event) { oldValue, newValue in
                if let newValue,
                   newValue != mutable
                {
                    mutable = newValue
                    textIsFocused = true
                }
            }
        }
    }
}

#Preview {
    List {
        VoyageeventEditorRow(event: .constant(.init(location: LocationSnippet.random.coordinate.codable)))
    }
    .locationManager()
}
