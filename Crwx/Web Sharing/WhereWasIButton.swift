//
//  WhereWasIButton.swift
//  Mewx
//
//  Created by Matthew Goacher on 9/18/25.
//

import SwiftUI
import CoreLocation
import FoundationUI

struct WhereWasIButton: View {
    let start: Date
    let end: Date
    let track: [TrackPoint]
    @State private var isPresented = false
    @State private var date: Date = .now
    @State private var result: CLLocationCoordinate2D?
    private var seconds: Binding<Int> {
        .init {
            Calendar.current.dateComponents([.second], from: date).second ?? 0
        } set: { newValue in
            var components = Calendar.current.dateComponents([.month, .day, .year, .hour, .minute, .second], from: date)
            components.second = newValue
            if let d = Calendar.current.date(from: components) {
                self.date = d
            }
        }

    }
    var body: some View {
        Button {
            isPresented = true
        } label: {
            Label("Where Was I?", systemImage: "location.magnifyingglass")
        }
        .onChange(of: start, initial: true) { oldValue, newValue in
            date = newValue
        }
        .onChange(of: date, initial: true) { oldValue, newValue in
            result = updateResult(date: newValue)
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                List {
                    Group {
                        Section {
                            DatePicker("When", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                            HStack {
                                Text("Seconds")
                                TextField("Seconds", value: seconds, format: .number)
                                    .multilineTextAlignment(.trailing)
                                Stepper("Seconds", value: seconds, in: 0...59)
                            }
                            .labelsHidden()
                        }
                        Section {
                            Text(date, format: .dateTime.hour().minute().second().month(.defaultDigits).day().year(.twoDigits))
                            if let result {
                                CoordinateText(point: result)
                            }
                        }
                    }
                    .seaSection()
                }
                .cancelButton()
                .saveButton("Done")
                .navigationTitle("Where Was I At…?")
                .navigationBarTitleDisplayMode(.inline)
                .seaBackground(.darkSeaBlue)
            }
        }
    }
    private func updateResult(date: Date) -> CLLocationCoordinate2D? {
        if date <= start {
            return track.first?.coordinate
        }
        else if date >= end {
            return track.last?.coordinate
        }
        if let i = track.lastIndex(where: {
            if let d = $0.time,
               d < date
            { return true }
            else { return false }
        }), // find last point just before this time
           i < (track.count - 1), // must not be the last of all points
           let t1 = track[i].time, // get its time
           date.timeIntervalSince(t1) < 5.minute, // must be within 5 minutes
           let t2 = track[i+1].time, // get next time
           t2.timeIntervalSince(date) < 5.minute // must be within 5 minutes
        {
            // What's our portion of time from one to the next
            let percentAlong = date.timeIntervalSince(t1) / t2.timeIntervalSince(t1)
            // What's the distance along
            let c1 = track[i].coordinate
            let c2 = track[i+1].coordinate
            let distanceAlong = percentAlong * c1.distance(to: c2)
            // Who is the position at this distance and bearing
            return c1.projected(by: distanceAlong, bearing: c2.bearing(from: c1))
        }
        return nil
    }
}
