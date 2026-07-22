//
//  LockerPicker.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/22/26.
//

import SwiftUI
import WxSalt

struct LockerPicker: View {
    @Binding var value: StorageLocker?
    var body: some View {
        NavigationLink(destination: ListForm(value: $value)) {
            Text("Storage Locker")
                .badge(value?.description ?? "--")
        }
    }
}

#Preview {
    @Previewable @State var value: StorageLocker?
    NavigationStack {
        List {
            LockerPicker(value: $value)
                .seaSection()
        }
        .seaBackground()
    }
    .environment(\.wxColourScheme, .green)
}

fileprivate struct ListForm: View {
    @Binding var value: StorageLocker?
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List {
            PickerListLoop(options: StorageLocker.allCases, value: $value)
        }
        .seaBackground()
        .navigationTitle("Storage Locker")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button("Clear") {
                    value = nil
                    dismiss()
                }
            }
        }
    }
}
