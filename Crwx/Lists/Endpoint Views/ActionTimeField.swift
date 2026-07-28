//
//  ActionTimeField.swift
//  Crwx
//
//  Created by Matthew Goacher on 7/21/26.
//

import SwiftUI
import WxSalt

struct ActionTimeField: View {
    @Binding var value: ActionTime
    @State private var option: Option = .anytime
    @State private var date: Date = .now
    var body: some View {
        VStack(alignment: .leading) {
            Picker("Due to Shift", selection: $option) {
                ForEach(Option.allCases, id: \.rawValue) { o in
                    Text(o.rawValue).tag(o)
                }
            }
            if option.showsDate {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.graphical)
            }
        }
        .onChange(of: value, initial: true) { oldValue, newValue in
            if newValue != computedValue {
                option = newValue.option
                if let d = newValue.date {
                    date = d
                }
            }
        }
        .onChange(of: option) { oldValue, newValue in
            if value.option != newValue {
                value = computedValue
            }
        }
        .onChange(of: date) { oldValue, newValue in
            if let d = value.date,
               d != newValue
            {
                value = computedValue
            }
        }
    }
    fileprivate enum Option: String, CaseIterable {
        case never, anytime, on, before, after
        var showsDate: Bool {
            switch self {
            case .never, .anytime: false
            case .on, .before, .after: true
            }
        }
    }
    private var computedValue: ActionTime {
        switch option {
        case .never: return .never
        case .anytime: return .anytime
        case .on: return .on(date)
        case .before: return .before(date)
        case .after: return .after(date)
        }
    }
}
fileprivate extension ActionTime {
    var option: ActionTimeField.Option {
        switch self {
        case .never: .never
        case .anytime: .anytime
        case .on: .on
        case .before: .before
        case .after: .after
        }
    }
}

#Preview {
    @Previewable @State var value: ActionTime = .anytime
    List {
        Section {
            ActionTimeField(value: $value)
            Text(value.summary)
        }
        .seaSection()
    }
    .seaBackground()
    .environment(\.wxColourScheme, .green)
}
