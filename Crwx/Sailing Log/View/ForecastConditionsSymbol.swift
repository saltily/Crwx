//
//  ForecastConditionsSymbol.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/8/25.
//

import SwiftUI

struct ForecastConditionsSymbol: View {
    let forecast: ForecastSnippet?
    var body: some View {
        if let symbolName = forecast?.symbolName {
            Image(systemName: symbolName)
                .renderingMode(.original)
                .symbolVariant(.fill)
                .frame(height: 10)
        }
    }
}
