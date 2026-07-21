//
//  IsCheckedButton.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import SwiftUI

struct CheckToggleButton: View {
    @Binding var isOn: Bool
    var body: some View {
        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
            .frame(width: 36, height: 36)
            .font(.title)
            .fontWeight(isOn ? .regular : .thin)
            .contentShape(.circle)
            .onTapGesture {
                withAnimation {
                    isOn.toggle()
                }
            }
            .foregroundStyle(isOn ? .accentColor : Color.primary)
    }
}
struct CheckStateButton: View {
    @Binding var value: CheckedState
    var body: some View {
        Image(systemName: value.systemImage)
            .frame(width: 36, height: 36)
            .font(.title)
            .fontWeight(value.fontWeight)
            .contentShape(.circle)
            .onTapGesture {
                withAnimation {
                    value.advance()
                }
            }
            .foregroundStyle(value.isChecked ? .accentColor : Color.primary)
    }
}
