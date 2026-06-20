//
//  BackupActor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import Foundation
import SwiftData
import os

@ModelActor
final actor BackupActor {
    func backup() async throws -> Data {
        await logger.trace("Received instruction to backup")
        try Task.checkCancellation()
        let backupData = try await BackupData(context: modelContext)
        try Task.checkCancellation()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(backupData)
        await logger.info("Backup complete.")
        await logger.trace("\(backupData.summary)")
        return data
    }
}

enum BackupError: Error {
    case FailedToEncode
    case Aborted
    case FailedToDecode
    case MissingRelationship
}
