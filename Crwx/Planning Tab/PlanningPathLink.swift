//
//  PlanningPathLink.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import FoundationUI

struct PlanningPathLink: View {
    init(_ value: PlanningPath) {
        self.value = value
    }
    let value: PlanningPath
    var body: some View {
        NavigationLink(value.label, systemImage: value.systemImage, value: value)
    }
}

#Preview {
    PlanningPathLink(.harbours)
}
