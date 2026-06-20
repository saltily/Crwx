//
//  SwipeToShareModifier.swift
//  Mewx
//
//  Created by Matthew Goacher on 8/29/25.
//

import SwiftUI
import FoundationUI
import os
import FoundationSalt

struct SwipeToShareModifier: ViewModifier {
    let action: () async -> ()
    func body(content: Content) -> some View {
        content
            .swipeActions(edge: .leading) {
                Button(systemImage: "square.and.arrow.up") {
                    Task {
                        await action()
                    }
                }
                .tint(.blue)
            }
    }
}
extension View {
    func swipeToShare(action: @escaping () async -> ()) -> some View {
        modifier(SwipeToShareModifier(action: action))
    }
    func isSharing(_ state: ShareState) -> some View {
        modifier(ShareStateFeedbackModifier(model: state))
    }
}
@Observable
final class ShareState {
    var state: S = .idle
    func start() {
        state = .uploading
    }
    func error(_ error: any Error) {
        state = .error
        logger.critical("There was an error trying to share: \(error)")
        Task {
            do {
                try await Task.sleep(seconds: 3)
                state = .idle
            } catch {
                state = .idle
            }
        }
    }
    func complete() {
        state = .onPasteboard
        Task {
            do {
                try await Task.sleep(seconds: 3)
                state = .idle
            } catch {
                state = .idle
            }
        }
    }
    enum S {
        case idle, uploading, onPasteboard, error
    }
}
struct ShareStateFeedbackModifier: ViewModifier {
    @Bindable var model: ShareState
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                if model.state != .idle {
                    HStack {
                        switch model.state {
                        case .idle:
                            EmptyView()
                        case .uploading:
                            ProgressView()
                            Text("Uploading…")
                        case .onPasteboard:
                            Text("Link is on pasteboard")
                        case .error:
                            Text("Failed to upload")
                                .foregroundStyle(.pink)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial)
                }
            }
    }
}
