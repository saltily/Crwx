//
//  FuelEditorRow.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 4/6/24.
//

import SwiftUI
import FoundationSalt

struct FuelEditorRow: View {
    @Binding var model: FuelSounding?
    private var inches: Binding<Double> {
        .init {
            model?.inches ?? 0
        } set: { newValue in
            model?.inches = newValue.nilIfZero
        }
    }
    private var gals: Double {
        model?.gallons ?? 0
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack {
                Stepper("Fuel", value: inches, step: 0.125)
                Text("\(inches.wrappedValue.eighths) in")
                    .frame(width: 75, alignment: .trailing)
            }
            HStack {
                Slider(value: inches, in: 0...22, step: 0.125)
                    .tint(.yellow)
                let s = gals.formatted(.number.precision(.fractionLength(0...1)))
                Text("\(s) gal")
                    .frame(width: 75, alignment: .trailing)
                    .foregroundStyle(gals > 45 ? .red : .primary)
            }
        }
    }
}
extension Double {
    var eighths: String {
        let (whole, fraction) = (8 * self).rounded.quotientAndRemainder(dividingBy: 8)
        if whole == 0 && fraction == 0 { return "0" }
        if fraction == 8 { return "\(whole + 1)" }
        let fractionString =
        switch fraction {
        case 1: "1/8"
        case 2: "1/4"
        case 3: "3/8"
        case 4: "1/2"
        case 5: "5/8"
        case 6: "3/4"
        case 7: "7/8"
        default: ""
        }
        if whole == 0 {
            return fractionString
        }
        else if fractionString.isEmpty {
            return "\(whole)"
        }
        else {
            return "\(whole)-\(fractionString)"
        }
    }
}

#Preview {
    Form {
        FuelEditorRow(model: .constant(.random))
    }
    .preferredColorScheme(.dark)
}
