//
//  ChooseAnchorageButton.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/28/25.
//

import SwiftUI
import WxSalt
import FoundationUI

struct ChooseAnchorageButton: View {
    @Binding var isPresented: Bool
    var body: some View {
        Button("Choose Anchorage", systemImage: "location.magnifyingglass") {
            isPresented = true
        }
    }
}

struct AnchorageChooserSheet: ViewModifier {
    @Binding var isPresented: Bool
    @AnchorageIntent private var intent
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                NavigationStack {
                    AnchorageChooser(intent: $intent).seaBackground()
                        .cancelButton()
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
    }
}
extension View {
    func anchorageChooser(isPresented: Binding<Bool>) -> some View {
        modifier(AnchorageChooserSheet(isPresented: isPresented))
    }
}
