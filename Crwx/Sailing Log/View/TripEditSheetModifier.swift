//
//  TripEditSheetModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/17/25.
//

import SwiftUI
import WxSalt

struct TripEditSheetModifier: ViewModifier {
    @Bindable var trip: Trip
    @State private var isPresented: Bool = false
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Button("Edit") {
                        isPresented = true
                    }
                }
            }
            .fullScreenCover(isPresented: $isPresented) {
                NavigationStack {
                    TripEditor(trip: trip)
                        .toolbar {
                            ToolbarItem {
                                Button("Done", role: .cancel) {
                                    isPresented = false
                                }
                                .fontWeight(.bold)
                            }
                        }
                        .seaBackground(.flat)
                }
            }
    }
}
extension View {
    func editSheet(_ trip: Trip) -> some View {
        modifier(TripEditSheetModifier(trip: trip))
    }
}
