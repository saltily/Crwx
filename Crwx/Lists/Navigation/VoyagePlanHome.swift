//
//  VoyagePlanHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct VoyagePlanHome: View {
    var body: some View {
        List {
            Section {
                Text("Similar to editing the current cruise in the cruises history list.")
                Text("We're interested in the current or next cruise.  If no current or next cruise, button to create one right here.")
                Text("Besides just choosing the colour and stops, we should also be able to indicate the number of days we're interested in, the likely start day if we know it, the likely passengers.  These are things that can help us with the menu even before we know where we want to go.")
                Text("It will also be handy to simply review the marine forecast for the days in question.  And even be alerted to when we're close enough with the forecast to get into planning.")
                Text("The history button can simply link to the same place that we have in history.  But better to convert that over to a navigation linking path before hooking that button up.  Otherwise preloading incursion of unnecessary views in the hierarchy.")
            }
            .seaSection()
        }
        .toolbar {
            ToolbarItem {
                Button(systemImage: "clock") {
                    
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VoyagePlanHome()
            .navigationTitle("Voyage Plan")
            .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
