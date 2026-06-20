//
//  SwipeEditHarbour.swift
//  Mewx
//
//  Created by Matthew Goacher on 4/4/25.
//

import SwiftUI
import SwiftData
import FoundationUI

struct SwipeEditHarbour: ViewModifier {
    @Bindable var harbour: Harbour
    @State private var showEditor = false
    @Environment(\.modelContext) private var context
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading) {
                Button(systemImage: "pencil") {
                    showEditor = true
                }
                .tint(.blue)
            }
            .fullScreenCover(isPresented: $showEditor) {
                NavigationStack {
                    HarbourDetail(harbour: harbour)
                        .cancelButton()
                        .saveButton("Done") {
                            try? context.save()
                        }
                }
            }
    }
}

extension View {
    func swipeEdit(harbour: Harbour) -> some View {
        modifier(SwipeEditHarbour(harbour: harbour))
    }
}
