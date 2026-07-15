//
//  SeasonalChecklistsHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt

struct SeasonalChecklistsHome: View {
    var body: some View {
        List {
            Section("Spring") {
                ListingPathLink(.springFitOut)
                ListingPathLink(.springLaunch)
                ListingPathLink(.springUprig)
                ListingPathLink(.springLoading)
            }
            .seaSection()
            
            Section("Fall") {
                ListingPathLink(.fallOffloading)
                ListingPathLink(.fallDownrig)
                ListingPathLink(.fallHaulout)
                ListingPathLink(.fallLayup)
            }
            .seaSection()
            
            Section("Winter") {
                ListingPathLink(.winterMaintenance)
            }
            .seaSection()
            
            Section {
                Text("Might be nice if app defaults remembers the last seasonal checklist we were doing and then when you first navigate to seasonal checklist, it could auto-drill an extra layer in.  Or just do the next checklist thing with checkmarks similar to what I discussed for cruising.")
            }
            .seaSection()
        }
    }
}

#Preview {
    NavigationStack {
        SeasonalChecklistsHome()
            .navigationTitle("Seasonal Checklists")
            .seaBackground()
            .navigationDestination(for: ListingPath.self) { path in
                ListingPathDestinationView(path: path)
                    .navigationTitle(path.label)
                    .seaBackground()
            }
    }
    .environment(\.wxColourScheme, .green)
}
