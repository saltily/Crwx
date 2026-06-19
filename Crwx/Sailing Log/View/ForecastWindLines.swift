//
//  ForecastWindLines.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/12/24.
//

import SwiftUI

struct ForecastWindLines: View {
    @Binding var winds: [WindSnippet]
    let text: String
    var body: some View {
        if winds.count == 1 {
            NavigationLink(destination: WindEditor(wind: $winds[0], text: text)) {
                WindLine(wind: winds[0])
            }
            .swipeActions() {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    winds = []
                }
            }
        }
        else if winds.count == 2 {
            NavigationLink(destination: WindEditor(wind: $winds[0], text: text)) {
                WindLine("1st Wind", wind: winds[0])
            }
            .swipeActions() {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    winds.remove(at: 0)
                }
            }
            NavigationLink(destination: WindEditor(wind: $winds[1], text: text)) {
                WindLine("2nd Wind", wind: winds[1])
            }
            .swipeActions() {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    winds.remove(at: 1)
                }
            }
        }
        if winds.count < 2 {
            Button {
                withAnimation {
                    winds.append(.init(speed: 0..<0))
                }
            } label: {
                Label("Add Wind", systemImage: "plus")
            }
        }    }
}

#Preview {
    NavigationStack {
        Form {
            ForecastWindLines(winds: .constant(.random), text: "Some sort of forecast text")
        }
    }
}
