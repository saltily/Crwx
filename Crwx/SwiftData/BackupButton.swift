//
//  BackupButton.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import SwiftUI

struct BackupButton: View {
    @Environment(\.modelContext) private var context
    var body: some View {
        let actor = BackupActor(modelContainer: context.container)
        ShareLink("Export", item: actor, preview: .init("Entire contents of database as json text."))
    }
}

#Preview {
    ShareLink(item: "Bob")
    BackupButton()
}

extension BackupActor: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { actor in
            try await actor.backup()
        }
        .suggestedFileName("Mewx Backup")
    }
}
