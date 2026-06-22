//
//  AddCruiseButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/6/25.
//

import SwiftUI
import FoundationUI
import SwiftData
import WxSalt

struct AddCruiseButton: View {
    @State private var model: CruiseViewModel?
    @Environment(\.modelContext) private var context
    var body: some View {
        Button(systemImage: "plus") {
            let new = CruiseViewModel(modelContainer: context.container)
            if let lastKnownHarbour = Trip.lastTrip(in: context)?.endHarbour {
                new.add(harbour: lastKnownHarbour)
            }
            model = new
        }
        .fullScreenCover(item: $model) { model in
            NavigationStack {
                CruiseForm(model: model)
                    .seaBackground(.flat)
                    .cancelButton()
                    .navigationTitle("New Cruise")
                    .navigationBarTitleDisplayMode(.inline)
                    .saveButton {
                        try model.save(in: context)
                    }
            }
        }
    }
}

#Preview {
    AddCruiseButton()
}
