//
//  ReturnToWeatherModifier.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/17/25.
//

import SwiftUI
import WxSalt

struct ReturnToWeatherModifier: ViewModifier {
    @Wx private var wx
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        wx.config.showVoyageLog = false
                    } label: {
                        Image(systemName: "cloud.sun")
                            .frame(width: 40)
                    }
                }
            }
    }
}

extension View {
    func returnToWx() -> some View {
        modifier(ReturnToWeatherModifier())
    }
}
