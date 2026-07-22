//
//  CategoryPicker.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import SwiftUI
import WxSalt

struct CategoryPicker: View {
    @Binding var value: PackedCategory?
    var body: some View {
        NavigationLink(destination: ListForm(value: $value)) {
            Text("Category")
                .badge(value?.rawValue ?? "--")
        }
    }
}

#Preview {
    @Previewable @State var value: PackedCategory?
    NavigationStack {
        List {
            CategoryPicker(value: $value)
                .seaSection()
        }
        .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}


fileprivate struct ListForm: View {
    @Binding var value: PackedCategory?
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List {
            PickerListLoop(options: customOptions, value: $value)
            PickerListLoop(options: matchingOptions, value: $value)
        }
        .seaBackground()
        .navigationTitle("Category")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem {
                Button("Clear") {
                    value = nil
                    dismiss()
                }
            }
        }
    }
    private var customOptions: [PackedCategory] {
        [
            value?.isCustom == true ? value : nil,
            customOption?.isCustom == true ? customOption : nil
        ].compactMap({ $0 })
    }
    private var customOption: PackedCategory? {
        guard !searchText.isEmpty else { return nil }
        return .init(rawValue: searchText)
    }
    private var matchingOptions: [PackedCategory] {
        guard !searchText.isEmpty else { return PackedCategory.allCases }
        return PackedCategory.allCases.filter({
            $0.rawValue.localizedStandardContains(searchText)
        })
    }
}

struct PickerListLoop<V>: View where V: RawRepresentable, V.RawValue == String, V: CustomStringConvertible {
    let options: [V]
    @Binding var value: V?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Section {
            ForEach(options, id: \.rawValue) { o in
                Button {
                    value = o
                    dismiss()
                } label: {
                    HStack {
                        Text(o.description)
                        Spacer()
                        if let value,
                           value == o
                        {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.accentColor)
                        }
                    }
                }
            }
        }
        .tint(.primary)
        .seaSection()
    }
}
