//
//  CommentsRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 7/5/25.
//

import SwiftUI
import FoundationUI
import FocusOnAppear
import FoundationSalt
import SwiftData
import WxSalt

struct CommentsRow: View {
    @Binding var value: String
    let passengers: String
    @State private var isPresented = false
    @State private var text: String = ""
    @Environment(\.modelContext) private var context
    var body: some View {
        Button {
            text = value
            isPresented = true
        } label: {
            Label {
                PlaceholderText(value.paragraphs.last?.trimmingRight(in: .whitespaces) ?? "", placeholder: "Add comments…")
                    .lineLimit(1)
                    .truncationMode(.head)
            } icon: {
                Image(systemName: "pencil")
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                List {
                    Section {
                        TextField("Comments", text: $text, axis: .vertical)
                            .lineLimit(5...)
                            .focusOnAppear()
                    } footer: {
                        Text(passengers)
                    }
                    .seaSection()
                }
                .seaBackground(.darkSeaBlue)
                .navigationTitle("Comments")
                .navigationBarTitleDisplayMode(.inline)
                .cancelButton()
                .saveButton {
                    value = text
                    try context.save()
                }
            }
        }
    }
}

