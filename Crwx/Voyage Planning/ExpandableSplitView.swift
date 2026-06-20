//
//  ExpandableSplitView.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 8/8/25.
//

import SwiftUI
import FoundationUI

struct ExpandableSplitView<Top, Bottom>: View where Top: View, Bottom: View {
    let topCollapsedHeight: CGFloat
    let bottomCollapsedHeight: CGFloat
    @Binding var isExpanded: Bool
    @ViewBuilder var top: () -> Top
    @ViewBuilder var bottom: () -> Bottom
    var body: some View {
        GeometryReader { geometry in
            let viewHeight = geometry.size.height
            let maxTopHeight = max(topCollapsedHeight, viewHeight - bottomCollapsedHeight)
            let topHeight = isExpanded ? topCollapsedHeight : maxTopHeight
            let bottomHeight = max(bottomCollapsedHeight, viewHeight - topHeight)
            ZStack {
                VStack(spacing: 0) {
                    top()
                        .frame(height: topHeight)
                        .animation(.default, value: isExpanded)
                        .frame(maxWidth: .infinity)
                    bottom()
                        .frame(height: bottomHeight)
                        .animation(.default, value: isExpanded)
                        .frame(maxWidth: .infinity)
                }
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.up")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())
                .mapAlignment(.bottomTrailing)
            }
        }
    }
}
