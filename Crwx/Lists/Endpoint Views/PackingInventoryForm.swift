//
//  PackingInventoryForm.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/23/26.
//

import SwiftUI
import WxSalt

struct PackingInventoryForm: View {
    @Bindable var value: PackableItem.Inventory
    let isConsumable: Bool
    var body: some View {
        InventoryQuantityValueField("Boat:", value: $value.quantityOnBoat) {
            value.incrementOnBoat()
        } onDecrement: {
            value.decrementOnBoat(consumable: isConsumable)
        }
        .disabled(!value.includeInBoatInventory)
        .opacity(value.includeInBoatInventory ? 1 : 0.5)
        InventoryQuantityValueField("Shore:", value: $value.quantityOnShore) {
            value.incrementOnShore()
        } onDecrement: {
            value.decrementOnShore()
        }
        .disabled(!value.includeInShoreInventory)
        .opacity(value.includeInShoreInventory ? 1 : 0.5)
        Toggle("Include in boat inventory.", isOn: $value.includeInBoatInventory)
        Toggle("Include in shore inventory.", isOn: $value.includeInShoreInventory)
    }
}

#Preview {
    @Previewable @State var value: PackableItem.Inventory = .init()
    List {
        Section("Consumable") {
            PackingInventoryForm(value: value, isConsumable: true)
        }
        .seaSection()
        Section("Asset") {
            PackingInventoryForm(value: value, isConsumable: false)
        }
        .seaSection()
    }
    .seaBackground()
    .environment(\.wxColourScheme, .green)
}

struct InventoryQuantityValueField: View {
    init(_ label: String, value: Binding<Double>, onIncrement: @escaping () -> (), onDecrement: @escaping () -> ()) {
        self.label = label
        self._value = value
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }
    let label: String
    @Binding var value: Double
    let onIncrement: () -> ()
    let onDecrement: () -> ()
    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .fixedSize()
            Spacer()
            TextField("1.0", value: $value, format: .number)
                .multilineTextAlignment(.trailing)
                .padding(.trailing, 10)
            Stepper("Step", onIncrement: onIncrement, onDecrement: onDecrement)
//            Stepper("Step", value: $value)
                .labelsHidden()
        }
    }
}
