//
//  YearPicker.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import SwiftUI
import SwiftData

struct YearPicker: View {
    @Query private var trips: [Trip]
    var body: some View {
        PickerView(years: years)
    }
    private var years: [Int] {
        var years = trips.map {
            $0.date.year
        }.set
        years.insert(Date.now.year)
        return years.sorted()
    }
}

#Preview {
    YearPicker()
}

fileprivate struct PickerView: View {
    let years: [Int]
    @Year private var year
    var body: some View {
        Picker("Year", selection: $year) {
            ForEach(years.reversed(), id: \.self) { y in
                Text(y, format: .number.grouping(.never))
            }
        }
    }
}
