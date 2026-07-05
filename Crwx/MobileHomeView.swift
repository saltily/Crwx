//
//  MobileHomeView.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/19/26.
//

import SwiftUI
import WxSalt
import FoundationSalt

struct MobileHomeView: View {
    @AppStorage(.crwxTabKey) private var tab = TabValue.log
    @State private var wx = WxEngine()
    var body: some View {
        TabView(selection: $tab) {
            
            // MARK: 1. Voyage Log
            Tab("Log", systemImage: "book.closed", value: TabValue.log) {
                VoyageLogHome()
            }
            
            // MARK: 2. Chart Navigator
            Tab("Navigator", systemImage: "safari", value: TabValue.chart) {
                NavigationStack {
                    NavigationHome()
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            
            // MARK: 3. Planning
            Tab("Plan", systemImage: "list.bullet.clipboard", value: TabValue.plan) {
                NavigationStack {
                    PlanningHome()
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            
        }
        .environment(wx)
    }
    enum TabValue: Int {
        case log, chart, plan
    }
}

#Preview {
    MobileHomeView()
}

extension String {
    static let crwxTabKey = "com.saltily.Crwx.tabKey" // MobileHomeView.TabValue: Int
}
