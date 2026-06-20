//
//  PointText.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 11/30/23.
//

import SwiftUI
import CoreLocation
import FoundationUI
import SwiftData
import FoundationSalt

struct PointText: View {
    init(_ point: CLLocation, completion: @escaping (String) -> Void = ({ _ in })) {
        self.point = point
        self.completion = completion
    }
    let point: CLLocation
    private var completion: (String) -> Void
    @State private var placeName: String?
    @State private var lookupError: Error?
    @Environment(\.modelContext) private var context
    var body: some View {
        PlaceholderText(placeName ?? "")
            .errorAlert(error: $lookupError)
            .task {
                await lookupPlace()
            }
            .onChange(of: point) { oldValue, newValue in
                Task {
                    await lookupPlace()
                }
            }
    }
    private func lookupPlace() async {
        do {
            placeName = try await point.lookupName(in: context.container)
            if let placeName {
                completion(placeName)
            }
        } catch {
            lookupError = error
        }
    }
}

#Preview {
    PointText(.default)
}
