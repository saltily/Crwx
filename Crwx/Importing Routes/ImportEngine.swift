//
//  ImportEngine.swift
//  Mewx (iOS)
//
//  Created by Matthew Goacher on 2/19/25.
//

import SwiftUI
import SwiftData
import FoundationSalt
import FoundationUI
import os
import WxSalt

@Observable
final class ImportEngine: ProgressEngine {
    init(container: ModelContainer) {
        self.container = container
    }
    let container: ModelContainer
    var isRunning: Bool = false
    var error: (any Error)?
    
    // MARK: Running
    func start() {
        self.run()
        
        // 1. Load files
        step = .loadingFiles
        catching {
            guard let groupContainer = URL.appGroupContainer
            else { throw ImportError.MissingGroupContainer }
            let allFiles = groupContainer.contents.filter {
                $0.pathExtension.lowercased().isIn("gpx", "xml", "nob")
            }
            let gpxParsers: [GpxParser] = try allFiles.compactMap {
                try .init(url: $0)
            }
            let nobParsers: [NobParser] = try allFiles.compactMap {
                try .init(url: $0)
            }
            self.logger?.trace("We found \(gpxParsers.count.appending("gpx parser", "gpx parsers"))")
            self.logger?.trace("We found \(nobParsers.count.appending("nob parser", "nob parsers"))")

            // 2. Load GPX
            if !gpxParsers.isEmpty {
                self.stepTwo(gpxParsers: gpxParsers, nobParsers: nobParsers)
            }
            // 3. Parse NOB
            else if !nobParsers.isEmpty {
                self.stepThree(nobParsers: nobParsers)
            }
            // 4. Cleanup Stray Files
            else {
                try self.stepFour()
            }
            
        }
    }
    
    // MARK: 2. Load GPX
    private func stepTwo(gpxParsers: [GpxParser], nobParsers: [NobParser]) {
        let container = self.container
        self.step = .parsingGpx(self.newTracker(totalCount: gpxParsers.totalCount) { tracker in
            let actor = GpxActor(modelContainer: container)
            try await actor.load(parsers: gpxParsers, tracker: tracker)
        } andThen: {
            // go to the next step or end
            if !nobParsers.isEmpty {
                self.stepThree(nobParsers: nobParsers)
            } else {
                try self.stepFour()
            }
        })
    }
    
    // MARK: 3. Load NOB
    private func stepThree(nobParsers: [NobParser]) {
        let container = self.container
        self.step = .parsingNob(self.newTracker(totalCount: nobParsers.totalCount) { tracker in
            let actor = NobActor(modelContainer: container)
            try await actor.load(parsers: nobParsers, tracker: tracker)
        } andThen: {
            // go to the next step or end
            try self.stepFour()
        })
    }
    
    // MARK: 4. Cleanup
    private func stepFour() throws {
        self.step = .cleanup
        guard let groupContainer = URL.appGroupContainer
        else { throw ImportError.MissingGroupContainer }
        let allFiles = groupContainer.contents.filter {
            $0.pathExtension.lowercased().isIn("gpx", "xml", "nob")
        }
        if !allFiles.isEmpty {
            logger?.warning("There were \(allFiles.count.appending("stray file", "stray files"))")
            for url in allFiles {
                try FileManager.default.removeItem(at: url)
            }
        }
        end()
    }

    // MARK: Optional State
    var step: Step = .idle
    var logger: Logger? = .init(subsystem: "com.saltily.Mewx", category: "Import")
    enum Step {
        case loadingFiles
        case parsingGpx(ProgressTracker<Void>)
        case parsingNob(ProgressTracker<Void>)
        case cleanup
        case idle
        var tracker: ProgressTracker<Void>? {
            switch self {
            case .parsingGpx(let t), .parsingNob(let t): return t
            default: return nil
            }
        }
    }
}

// MARK: Engine Protocol
extension ImportEngine {
    func cancelTasks() {
        step.tracker?.cancel()
    }
    func resetState() {
        step = .idle
    }
}

// MARK: Menu Command
#if os(macOS)
struct ImportCommand: Commands {
    var body: some Commands {
        CommandGroup(before: .importExport) {
            ProgressCommand(ImportEngine.self) { engine in
                Button("Import QFX") {
                    //                    engine?.start(accountId: accountId)
                }
                //                .keyboardShortcut("i", modifiers: [.command, .control])
            }
        }
    }
}
#endif

enum ImportError: Error {
    case MissingGroupContainer
}
