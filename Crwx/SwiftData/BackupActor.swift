//
//  BackupActor.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/14/25.
//

import Foundation
import SwiftData

@ModelActor
final actor BackupActor {
    func backup() async throws -> Data {
        logger.trace("Received instruction to backup")
        try Task.checkCancellation()
        let backupData = try BackupData(context: modelContext)
        try Task.checkCancellation()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(backupData)
        logger.info("Backup complete.")
        logger.trace("\(backupData.summary)")
        return data
    }
}

enum BackupError: Error {
    case FailedToEncode
    case Aborted
    case FailedToDecode
    case MissingRelationship
}
