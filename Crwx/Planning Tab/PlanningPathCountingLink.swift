//
//  PlanningPathCountingLink.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import SwiftData
import FoundationUI

struct PlanningPathCountingLink<T>: View where T: PersistentModel {
    init(_ value: PlanningPath, type: T.Type) {
        self.value = value
    }
    let value: PlanningPath
    @State private var count: Int = 0
    var body: some View {
        NavigationLink(value: value) {
            Label(value.label, systemImage: value.systemImage)
                .badge(count)
                .fetchCount(T.self, into: $count)
        }
    }
}

#Preview {
    PlanningPathCountingLink(.harbours, type: Harbour.self)
}

struct PlanningPathFilteredCountingLink<T>: View where T: PersistentModel {
    init(_ value: PlanningPath, filter: Predicate<T>) {
        self.value = value
        self.filter = filter
    }
    let value: PlanningPath
    let filter: Predicate<T>
    @State private var count: Int = 0
    var body: some View {
        NavigationLink(value: value) {
            Label(value.label, systemImage: value.systemImage)
                .badge(count)
                .fetchCount(filter: filter, into: $count)
        }
    }
}
