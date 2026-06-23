//
//  AllTripYears.swift
//  Crwx
//
//  Created by Matthew Goacher on 6/23/26.
//

import SwiftUI
import SwiftData
import FoundationSalt
import WxSalt

struct AllTripYears: View {
    @Query private var trips: [Trip]
    var body: some View {
        List {
            Section {
                ForEach(years, id: \.self) { i in
                    NavigationLink(value: TripYearValue(rawValue: i)) {
                        Text(i, format: .number.grouping(.never))
                            .badge(count(year: i))
                    }
                }
            }
            .seaSection()
        }
        .navigationTitle("Trip Years")
    }
    private var years: [Int] {
        var years = trips.map {
            $0.date.year
        }.set
        years.insert(Date.now.year)
        return years.sorted().reversed()
    }
    private func count(year: Int) -> Int {
        trips.count(where: {
            $0.date.year == year
        })
    }
}
struct TripYearValue: RawRepresentable, Hashable {
    let rawValue: Int
}

#Preview {
    AllTripYears()
}
