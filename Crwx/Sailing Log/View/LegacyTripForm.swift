//
//  LegacyTripForm.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/16/24.
//

import SwiftUI
import FoundationSalt
import SwiftData
import FoundationUI
import WxSalt

/// I'm still using this to swipe and add a trip at a custom date after a past trip.
struct LegacyTripForm: View {
    @Binding var date: Date
    let didSave: (Trip) -> ()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .seaSection()
            }
            .navigationTitle("Add Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        let trip = Trip()
                        trip.date = date.withoutTime
                        context.insert(trip)
                        dismiss()
                        Task {
                            await MainActor.run {
                                didSave(trip)
                            }
                        }
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    List {
        
    }
    .sheet(isPresented: .constant(true)) {
        LegacyTripForm(date: .constant(.now)) { _ in }
    }
}


struct LegacyTripSheetModifier: ViewModifier {
    init(startingDate: Date = .now, proxy: ScrollViewProxy) {
        self._date = .init(initialValue: startingDate)
        self.proxy = proxy
    }
    @State private var date: Date
    let proxy: ScrollViewProxy
    @State private var isPresented = false
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading) {
                Button(systemImage: "plus.circle") {
                    isPresented = true
                }
                .tint(.accentColor)
            }
            .sheet(isPresented: $isPresented) {
                LegacyTripForm(date: $date) { trip in
                    proxy.scrollTo(trip.persistentModelID)
                }
                .seaBackground(.flat)
                .presentationDetents([.height(500)])
            }
    }
}
extension View {
    func legacyTripSheet(_ proxy: ScrollViewProxy, date: Date = .now) -> some View {
        modifier(LegacyTripSheetModifier(startingDate: date, proxy: proxy))
    }
}

