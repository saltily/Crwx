//
//  TripMapSection.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/8/25.
//

import SwiftUI
import MapKit
import WxSalt

struct TripMapSection<Content>: View where Content: View {
    let corner: Alignment
    @ViewBuilder var content: () -> Content
    @Environment(\.wxColourScheme) private var scheme
    var body: some View {
        content()
            .font(.footnote)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(scheme.darkSea.opacity(0.8))
            }
            .padding(5)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: corner)
    }
}

#Preview {
    List {
        ZStack {
            Map()
            TripMapSection(corner: .topLeading) {
                Text("Hi")
            }
        }
        .frame(height: 300)
        .listRowInsets(.init())
    }
    .seaBackground()
}
