//
//  SwipeMoveToList.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/22/26.
//

import SwiftUI
import FoundationUI

extension View {
    func swipeMoveToList(options: [PackingFilter.Style], item: PackableItem, didMove: @escaping () -> ()) -> some View {
        modifier(SwipeMoveToList(item: item, options: options, didMove: didMove))
    }
}
struct SwipeMoveToList: ViewModifier {
    @Bindable var item: PackableItem
    let options: [PackingFilter.Style]
    let didMove: () -> ()
    @State private var showSheet = false
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading) {
                if !options.isEmpty {
                    Button(systemImage: "arrow.up.arrow.down") {
                        showSheet = true
                    }
                    .tint(.blue)
                }
            }
            .confirmationDialog("Move to List", isPresented: $showSheet, titleVisibility: .visible) {
                ForEach(options, id: \.rawValue) { o in
                    let listingPath = o.listingPath
                    Button(listingPath.label, systemImage: listingPath.systemImage) {
                        item.state.status = o.status
                        // should already be due or wouldn't have appeared in this list
                        //                            item.state.due = .anytime
                        didMove()
                    }
                }
            }
    }
}
