//
//  SwipeExtractSegment.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/10/25.
//

import SwiftUI
import FoundationUI
import MapKit

struct SwipeExtractSegmentModifier: ViewModifier {
    let track: Track
    let segment: [TrackPoint]
    let disabled: Bool
    let didSave: () -> ()
    @State private var viewModel: TrackExtractViewModel?
    func body(content: Content) -> some View {
        content.swipeActions(edge: .leading, allowsFullSwipe: true) {
            if !disabled {
                Button("Extract", systemImage: "square.and.arrow.up") {
                    viewModel = .init(segment: segment, original: track)
                }
                .tint(.red)
            }
        }
        .sheet(item: $viewModel) { vm in
            NavigationStack {
                ExtractSegmentForm(vm: vm) {
                    didSave()
                }
                .navigationTitle("Extract Segment")
                .toolbarTitleDisplayMode(.inline)
                .seaBackground(.darkSeaBlue)
            }
        }
    }
}
extension View {
    func swipeExtract(segment: [TrackPoint], track: Track, disabled: Bool, didSave: @escaping () -> ()) -> some View {
        modifier(SwipeExtractSegmentModifier(track: track, segment: segment, disabled: disabled, didSave: didSave))
    }
}

struct ExtractSegmentForm: View {
    init(vm: TrackExtractViewModel, didSave: @escaping () -> ()) {
        self.vm = vm
        _model = .init(initialValue: vm)
        self.didSave = didSave
    }
    let vm: TrackExtractViewModel
    let didSave: () -> ()
    @State private var model: TrackExtractViewModel
    @Environment(\.modelContext) private var context
    var body: some View {
        List {
            Group {
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        SaltMap {
                            MapDot(vm.points.first?.first, tint: .black.opacity(0.5))
                            MapDot(vm.points.first?.last)
                            Polyline(model.points.allVisible)
                        }
                        .northUp()
                        .zoomDisabled()
                        .panningDisabled()
                        .minimumZoom(metresUp: 10_000)
                        SegmentRow(points: vm.points.first ?? [], colour: .red)
                    }
                    .listRowInsets(.init())
                    .frame(height: 300)
                }
                Section {
                    TextField("Name", text: $model.name)
                    TextField("Date", value: $model.date, format: .dateTime.month(.defaultDigits).day().year(.twoDigits))
                }
            }
            .seaSection()
        }
        .cancelButton()
        .saveButton {
            model.insert(into: context)
            try? context.save()
            didSave()
            return true
        }
    }
}
