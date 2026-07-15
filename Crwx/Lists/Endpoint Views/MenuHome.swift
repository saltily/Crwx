//
//  MenuHome.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/14/26.
//

import SwiftUI
import WxSalt
import FoundationUI

struct MenuHome: View {
    var body: some View {
        List {
            Section {
                Text("Closely and directly tied to a cruise.  Most interested in the current or next cruise, but possible browse history of cruises and menus.  We'll want to know a little about the cruise, chiefly how long it will be and who will be going so we can suit to tastes and do enough meals.  If there is no current cruise then create one and can also establish duration and passengers directly from this interface when creating.")
                Text("Fairly early on separate by meal and beef up the number of meals.  It's ok to do repeat meals and to have empty places waiting to be occupied by a meal.  Also include snacks.")
                Text("Quite common to pull from previous meals and snacks for ideas.  And also of course add new custom meals.  Will be able to draw in ingredient lists.  Won't know what needs to be purchased.  Will know what is typically prepared ahead.  Could be multiple recipes per meal.  Would be great to have images, attachments, and links to refer to when cooking the meal.  Also who will be preparing the meal.  Also possibly pack so meal ingredients are in order.  And think of which ingredients will spoil faster.  And indicate date and harbour name for the meal if known, and can drag to reorder accordingly and update as harbours adjust.  Images and attachments preferred over links because should assume we'll be offline.")
                Text("Much of this planning would be good at the computer.  And printing paper copies also a decent idea.  Also decent idea to share with others involved in planning and cooking.")
                Text("Move items to packing list only when ready.  Meals own their packing items.  Delete the meal, delete those items.  Those items are never pack until ready to pack for the cruise.  These actions can happen in the cruise pre-departure checklist.  As they go on, then review inventory and purchasing and packing needs.")
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
        MenuHome()
            .navigationTitle("Menu")
            .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}
