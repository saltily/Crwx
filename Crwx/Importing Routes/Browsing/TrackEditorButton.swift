//
//  TrackEditorButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 3/10/25.
//

import SwiftUI

struct TrackEditorButton: View {
    let mode: TrackMap.EditingMode
    @Binding var segments: [[TrackPoint]]
    let erasableIndex: (Int, Int)?
    let sliceableIndex: (Int, Int)?
    var body: some View {
        switch mode {
        case .slice:
            Button(systemImage: "scissors.circle") {
                if let path = sliceableIndex {
                    let segment = segments[path.0]
                    let front = segment[..<path.1].array
                    let back = segment[path.1...].array
                    segments[path.0] = back
                    segments.insert(front, at: path.0)
                } else if let path = erasableIndex {
                    let segment = segments[path.0]
                    let front = segment[...path.1].array
                    let back = segment[path.1...].array
                    segments[path.0] = back
                    segments.insert(front, at: path.0)
                }
            }
            .font(.title)
            .disabled(sliceableIndex == nil && erasableIndex == nil)
        case .erase:
            Button(systemImage: "scope") {
                if var point = segments[path: erasableIndex] {
                    point.isHidden = true
                    segments[path: erasableIndex] = point
                }
            }
            .font(.title3)
            .disabled(erasableIndex == nil)
        case .handle:
            Image(systemName: "circle")
                .opacity(0.3)
        }
    }
}
