//
//  ExposureEditor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/20/25.
//

import SwiftUI
import FoundationSalt
import WxSalt

struct ExposureEditor: View {
    @State private var palette: CompassExposure.Level = .protected
    @Binding var value: CompassExposure
    var legend: (any ExposureLegend)?
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 50) {
                    
                    // MARK: Circle
                    ZStack {
                        Circle()
                            .stroke(.primary.opacity(0.3), lineWidth: geometry.size.width/18)
                            .padding(geometry.size.width/18)
                            .overlay(
                                ZStack {
                                    ForEach(CompassDirection.cardinal) { direction in
                                        if let angle = direction.direction {
                                            WindWedge()
                                                .fill(value[direction]?.colour ?? .gray.opacity(0.3))
                                                .rotationEffect(.degrees(180))
                                                .rotationEffect(.degrees(angle.degrees))
                                        }
                                    }
                                }
                            )
                            .onTapGesture { point in
                                // is it in the circle?
                                let diameter = geometry.size.width - 100
                                let centre = CGPoint(x: diameter/2, y: diameter/2)
                                let distance = point.distance(to: centre)
                                let isInCircle = distance <= diameter/2
                                guard isInCircle else { return }
                                // which cardinal is it in?
                                let degrees = centre.angle(to: point).converted(to: .degrees).value.rounded(45)
                                let compass = CompassDirection(direction: .init(value: degrees, unit: .degrees))
                                // update the value
                                if value[compass] == palette {
                                    value[compass] = nil
                                } else {
                                    value[compass] = palette
                                }
                            }
                    }
                    .aspectRatio(1, contentMode: .fit)

                    // MARK: Palette Choices
                    VStack(alignment: .leading) {
                        PaletteOptionRow(palette: $palette, level: .protected, legend: legend?.description(for: .protected))
                        PaletteOptionRow(palette: $palette, level: .some, legend: legend?.description(for: .some))
                        PaletteOptionRow(palette: $palette, level: .exposed, legend: legend?.description(for: .exposed))
                    }
                }
                .frame(height: geometry.size.height)
            }
            .padding(.horizontal, 50)
        }
        .toolbarTitleDisplayMode(.inline)
    }
    
}
fileprivate struct PaletteBullet: View {
    let level: CompassExposure.Level
    let isSelected: Bool
    var body: some View {
        Circle()
            .fill(level.colour)
            .padding(3)
            .background {
                Circle()
                    .stroke(.primary.opacity(isSelected ? 1 : 0), lineWidth: 2)
            }
    }
}
fileprivate struct PaletteOptionRow: View {
    @Binding var palette: CompassExposure.Level
    let level: CompassExposure.Level
    let legend: String?
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            PaletteBullet(level: level, isSelected: palette == level)
                .frame(width: 30)
                .alignmentGuide(.firstTextBaseline) { dim in
                    dim[VerticalAlignment.center] + 7
                }
            VStack(alignment: .leading) {
                Text(level.name)
                if let legend {
                    Text(legend)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1...)
                        .font(.caption2)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            palette = level
        }
    }
}

#Preview {
    NavigationStack {
        InteractivePreview()
            .navigationTitle("Wind Exposure")
    }
    .preferredColorScheme(.dark)
}
fileprivate struct InteractivePreview: View {
    @State private var exposure = CompassExposure()
    var body: some View {
        ExposureEditor(value: $exposure)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    ExposureSymbol(exposure: exposure)
                    Spacer()
                    ExposureSymbol(exposure: exposure.filtering(.southwest, .south, .southeast))
                    Spacer()
                    ExposureSymbol(exposure: exposure.filtering(.southwest, .south, .southeast).safe())
                }
                .padding(50)
            }
    }
}

struct ExposurePickerRow<Label>: View where Label: View {
    var title: String = ""
    @Binding var exposure: CompassExposure
    var legend: (any ExposureLegend)?
    @ViewBuilder var label: () -> Label
    var body: some View {
        NavigationLink(destination: ExposureEditor(value: $exposure, legend: legend).seaBackground(.darkSeaGreen).navigationTitle(title)) {
            HStack {
                label()
                Spacer()
                ExposureSymbol(exposure: exposure)
            }
        }
    }
}
extension ExposurePickerRow where Label == Text {
    init(_ label: String, exposure: Binding<CompassExposure>, legend: (any ExposureLegend)? = nil) {
        self.init(title: label, exposure: exposure, legend: legend) {
            Text(label)
        }
    }
}
