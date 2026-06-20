//
//  HarbourAtAGlance.swift
//  Mewx
//
//  Created by Matthew Goacher on 3/23/25.
//

import SwiftUI
import FoundationUI
import FoundationSalt

struct HarbourAtAGlance: View {
    @Bindable var harbour: Harbour
    var trimNotes = true
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(harbour.name)
                    .font(.headline)
                if harbour.webId != nil {
                    Image(systemName: "square.and.arrow.up")
                        .opacity(0.3)
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
                Spacer()
                BottomChunk(type: harbour.bottomType, depth: harbour.chartDepth, entrance: harbour.entranceDepth)
                    .font(.subheadline)
                ProtectionChunk(value: harbour.protectionScore)
            }
            .frame(height: 25)
            HStack {
                RatingChunk(value: harbour.rating, guideRating: harbour.guideRating)
                FacilitiesChunk(value: harbour.facilities)
                Spacer()
                Group {
                    WindChunk(value: harbour.windExposure)
                    SwellChunk(value: harbour.swellExposure)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            TextChunk(text: harbour.textSample, trim: trimNotes)
                .padding(.top, 5)
                .font(.footnote)
        }
    }
}


// MARK: Chunks
fileprivate struct RatingChunk: View {
    let value: Double?
    let guideRating: GuideRating?
    @State private var showMessage = false
    var body: some View {
        RatingSymbol(value, predicted: guideRating?.percentage)
            .foregroundStyle(.yellow)
            .font(.caption2)
            .ratingSpacing(1)
            .onTapGesture {
                showMessage = true
            }
            .alert("Cruising Guide", isPresented: $showMessage) {
                Button("Thanks") {}
            } message: {
                let s1 = (guideRating?.rawValue ?? 0).appending("star.", "stars.")
                let s2 = guideRating?.description ?? "Not rated."
                Text("\(s1)\n\(s2)")
            }
    }
}
fileprivate struct ProtectionChunk: View {
    let value: ProtectionScore?
    @State private var showMessage = false
    var body: some View {
        if let value {
            ProtectionSymbol(value: value)
                .tint(.secondary)
                .scaleEffect(0.8)
                .onTapGesture {
                    showMessage = true
                }
                .alert("Cruising Guide", isPresented: $showMessage) {
                    Button("Thanks") {}
                } message: {
                    Text("Protection level \(value.rawValue).\n\(value.description)")
                }
        }
    }
}
fileprivate struct FacilitiesChunk: View {
    let value: Facilities
    var body: some View {
        HStack(spacing: 5) {
            ForEach(value.facilities) { facility in
                Image(systemName: facility.systemImage)
            }
        }
        .foregroundStyle(.secondary)
        .font(.caption2)
    }
}
extension HarbourAtAGlance {
    struct WindChunk: View {
        let value: CompassExposure
        var body: some View {
            HStack {
                Image(systemName: "wind")
                ExposureSymbol(exposure: value)
            }
        }
    }
    struct SwellChunk: View {
        let value: CompassExposure
        var body: some View {
            HStack {
                Image(systemName: "water.waves")
                ExposureSymbol(exposure: value)
            }
        }
    }
    struct BottomChunk: View {
        let type: BottomType?
        let depth: Double?
        let entrance: Double?
        var body: some View {
            if type != nil || depth != nil || entrance != nil {
                HStack {
                    if let type {
                        Text(type.symbol)
                    }
                    if let depth {
                        let s = depth.formatted(.number.precision(.fractionLength(0...1)))
                        Text("\(s)ft")
                    }
                    if let entrance {
                        let s = entrance.formatted(.number.precision(.fractionLength(0...1)))
                        Text("(\(s)ft ent)")
                    }
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}
fileprivate struct TextChunk: View {
    let text: String?
    let trim: Bool
    var body: some View {
        if let text {
            Text(text)
                .lineLimit(1...(trim ? 2 : 100))
        }
    }
}
