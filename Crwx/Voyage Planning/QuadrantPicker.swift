//
//  QuadrantPicker.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/28/25.
//

import SwiftUI

struct QuadrantPicker: View {
    init(_ label: String, value: Binding<CompassQuadrant>) {
        self.label = label
        self._value = value
    }
    let label: String
    @Binding var value: CompassQuadrant
    var body: some View {
        Picker(label, selection: $value) {
            Text("North").tag(CompassQuadrant.north)
            Text("South").tag(CompassQuadrant.south)
            Text("East").tag(CompassQuadrant.east)
            Text("West").tag(CompassQuadrant.west)
        }
    }
}
