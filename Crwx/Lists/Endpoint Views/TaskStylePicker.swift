//
//  TaskStylePicker.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/15/26.
//

import SwiftUI
import WxSalt

struct TaskStylePicker: View {
    @Binding var value: CheckableTask.S
    var body: some View {
        Picker("Task Style", selection: $value) {
            ForEach(CheckableTask.S.allCases) { style in
                Image(systemName: style.systemImage).tag(style)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var style: CheckableTask.S = .plain
    List {
        TaskStylePicker(value: $style)
    }
    .seaBackground()
    .environment(\.wxColourScheme, .green)
}
