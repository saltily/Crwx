//
//  SwipeOrderUpShiftModifier.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/28/26.
//

import SwiftUI
import FoundationUI
import FoundationSalt

extension View {
    func swipeOrderUpShift(item: PackableItem) -> some View {
        modifier(SwipeOrderUpShiftModifier(item: item))
    }
}
struct SwipeOrderUpShiftModifier: ViewModifier {
    @Bindable var item: PackableItem
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading) {
                Button("Purchase", systemImage: "dollarsign") {
                    item.state.status = .purchase
                    item.state.due = .anytime
                }
                .tint(item.isDueForPurchase ? .secondary : .yellow)
                .disabled(item.isDueForPurchase)
                Button("Take Out", systemImage: "arrow.right") {
                    item.state.status = .shoreOnHand
                    item.state.due = .anytime
                    if item.state.inventory.quantityOnShore <= 0 {
                        item.state.inventory.quantityOnShore = 1
                    }
                }
                .tint(item.isDueToGoOut ? .secondary : .blue)
                .disabled(item.isDueToGoOut)
            }
    }
}

fileprivate extension PackableItem {
    var isDueForPurchase: Bool {
        state.status == .purchase && state.due.isDue
    }
    var isDueToGoOut: Bool {
        state.status.isIn(.packed, .shoreOnHand) && state.due.isDue
    }
}
