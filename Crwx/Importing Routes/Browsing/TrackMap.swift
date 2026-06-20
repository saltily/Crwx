//
//  TrackMap.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import FoundationUI
import FoundationSalt
import MapKit
import SwiftData

struct TrackMap: View {
    @Bindable var track: Track
    var body: some View {
        NestOne(segments: $track.segments, track: track)
            .navigationTitle(track.name)
    }
    enum EditingMode {
        case slice, erase, handle
    }
}

fileprivate struct NestOne: View {
    init(segments: Binding<[[TrackPoint]]>, track: Track) {
        self._segments = segments
        self.track = track
        _region = .init(initialValue: .fitting(points: segments.wrappedValue.flatMap { $0 }))
    }
    @Binding var segments: [[TrackPoint]]
    @Bindable var track: Track
    @State private var copy: [[TrackPoint]] = []
    @State private var colours: ColorPattern = .red
    @State private var region: MKCoordinateRegion
    @State private var editingMode: TrackMap.EditingMode = .handle
    @Environment(\.modelContext) private var context
    var body: some View {
        ZStack {
            let erasableIndex = erasablePath
            let sliceableIndex = sliceablePath
            SaltMap(region: $region) {
                ForEach(0..<copy.count, id: \.self) { i in
                    Polyline(copy[i].visible, tint: colour(i: i))
                }
                let visiblePoints = visiblePoints
                ForEach(0..<visiblePoints.count, id: \.self) { i in
                    TrackDot(visiblePoints[i])
                }
                if editingMode.isIn(.erase, .slice),
                   let point = copy[path: erasableIndex]
                {
                    TrackDot(point, tint: .green)
                } else if editingMode == .slice,
                          let sliceableIndex
                {
                    let lhs = copy[sliceableIndex.0][sliceableIndex.1-1]
                    let rhs = copy[sliceableIndex.0][sliceableIndex.1]
                    Polyline([lhs,rhs], tint: .green)
                }
                MapDot(track.start, tint: .black.opacity(0.5))
                MapDot(track.end)
            }
            ZoomControlsOverlay(region: $region, showAll: .fitting(points: copy.allVisible), goMicro: true)
            EditingModeOverlay(mode: $editingMode)
            TrackEditorButton(mode: editingMode, segments: $copy, erasableIndex: erasableIndex, sliceableIndex: sliceableIndex)
            TrackHintsOverlay(track: track, cmg: track.cmg)
        }
        .onChange(of: segments, initial: true) { oldValue, newValue in
            copy = newValue
            region = .fitting(points: segments.allVisible)
        }
        .northUp()
        .schemedColorPattern($colours)
        .safeAreaInset(edge: .bottom) {
            List {
                ForEach(0..<copy.count, id: \.self) { i in
                    let segment = copy[i]
                    SegmentRow(points: segment, colour: colour(i: i))
                        .listRowInsets(.init())
                        .listRowBackground(Color.clear)
                        .swipeExtract(segment: segment, track: track, disabled: copy.count <= 1) {
                            copy.remove(at: i)
                        }
                        .swipeActions(edge: .trailing) {
                            if copy.count > 1 {
                                Button(systemImage: "trash") {
                                    copy.remove(at: i)
                                }
                                .tint(.red)
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button(systemImage: "arrow.left.arrow.right") {
                                copy[i] = segment.reversed()
                            }
                            .tint(.orange)
                        }
                }
            }
            .listStyle(.plain)
            .frame(height: min(150, copy.count.double.cgfloat * 50))
            .background(.thinMaterial)
        }
        .toolbar {
            if !copy.isEmpty,
              segments != copy
            {
                ToolbarItem {
                    Button("Save") {
                        segments = copy
                        track.remeasure()
                        try? context.save()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    private func colour(i: Int) -> Color {
        if copy.count > 1 {
            colours[i]
        } else {
            .red
        }
    }
    private var visiblePoints: [TrackPoint] {
        guard region.span.longitudeDelta < 0.0035 else { return [] }
        return copy.allVisible.filter {
            region.contains($0)
        }
    }
    private var erasablePath: (Int, Int)? {
        guard region.span.longitudeDelta < 0.0035 else { return nil }
        return copy.erasable(at: region.center)
    }
    private var sliceablePath: (Int, Int)? {
        guard region.span.longitudeDelta < 0.0035 else { return nil }
        return copy.sliceable(at: region.center)
    }
}
