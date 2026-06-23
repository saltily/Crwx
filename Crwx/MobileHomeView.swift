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
    var body: some View {
        TabView(selection: $tab) {
            
            // MARK: 1. Voyage Log
            Tab("Log", systemImage: "book.closed", value: TabValue.log) {
                VoyageLogHome()
            }
            
            // MARK: 2. Chart Navigator
            Tab("Navigator", systemImage: "safari", value: TabValue.chart) {
                NavigationStack {
                    GridHelper()
                        .scrollClipDisabled()
//                        .ignoresSafeArea()
                        .seaBackground()
                        .navigationTitle("Navigator")
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
