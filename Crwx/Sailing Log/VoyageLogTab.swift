//
//  VoyageLogTab.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import SwiftUI
import WxSalt

struct VoyageLogTab: View {
    @Wx private var wx
    var body: some View {
        NavigationStack {
            AllTripsView()
                .seaBackground()
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button {
                            wx.config.showVoyageLog = false
                        } label: {
                            Image(systemName: "cloud.sun")
                                .frame(width: 40)
                        }
                    }
                    ToolbarItem {
                        LogCommandsMenu()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

//#Preview {
//    WxNavigator { wx in
//        VoyageLogTab()
//            .seaBackground()
//            .onAppear {
//                wx.config.showVoyageLog = true
//            }
//    }
//    .locationManager()
//}
