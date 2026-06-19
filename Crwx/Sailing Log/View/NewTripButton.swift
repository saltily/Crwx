//
//  NewTripButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationUI
import SwiftData
import FoundationSalt

struct NewTripButton: View {
    @State private var model: PreDepartureViewModel?
    var body: some View {
        Button {
            let trip = Trip()
            trip.date = .now
            // if you insert the trip now, then this view will be taken out of the hierarchy and it won't listen for sheet dismissal
//            context.insert(trip)
            model = trip.predeparture
        } label: {
            HStack {
                Label("New Trip", systemImage: "plus")
                Spacer()
                Image(systemName: "cellularbars", variableValue: 0)
            }
        }
        .padding(.vertical)
        .sheet(item: $model, content: { model in
            PredepartureForm(model: model, isNew: true)
        })
    }
}

#Preview {
    List {
        Section {
            NewTripButton()
        } header: {
            Text(Date.now, format: .dateTime.month(.wide).year())
        }
    }
    .locationManager()
    .modelContainer(previewContainer)
}
