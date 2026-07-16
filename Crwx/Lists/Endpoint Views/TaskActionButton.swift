//
//  TaskActionButton.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import os


fileprivate struct TaskActionImage: View {
    let systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(.title)
            .fontWeight(.thin)
            .contentShape(.circle)
    }
}

struct TaskConfirmInventoryButton: View {
    var body: some View {
        TaskActionImage(systemName: "pencil.and.list.clipboard")
            .onTapGesture {
                logger.trace("Pull up inventory review of packable items in this task.")
            }
    }
}

struct TaskPackingListButton: View {
    var body: some View {
        TaskActionImage(systemName: ["plus.circle", "checklist"].randomElement()!)
            .onTapGesture {
                logger.trace("Either adding these items to the packing list or going to the packing list to see what's what.")
            }
    }
}

struct TaskProjectDrillButton: View {
    var body: some View {
        TaskActionImage(systemName: "chevron.right.circle")
    }
}
