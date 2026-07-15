//
//  TaskActionButton.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import os

struct TaskActionButton: View {
    let action: TaskAction
    var body: some View {
        Image(systemName: "chevron.right.circle")
            .font(.title)
            .fontWeight(.thin)
            .contentShape(.circle)
            .onTapGesture {
                logger.trace("Tap that shit for \(action.rawValue).")
            }
    }
}

#Preview {
    TaskActionButton(action: .daysailPack)
}
