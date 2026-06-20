//
//  HarbourDetailPane.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/21/25.
//

import SwiftUI

struct HarbourDetailPane: View {
    @Bindable var harbour: Harbour
    let isExpanded: Bool
    let tab: HarbourTab
    @Binding var selectedDestination: HarbourViewModel?
    var body: some View {
        switch tab {
        case .Info:
            HarbourInfoEditor(harbour: harbour, isExpanded: isExpanded)
        case .Destinations:
            DestinationsList(isExpanded: isExpanded, start: harbour, selectedDestination: $selectedDestination)
        }
    }
}
