//
//  ShareViewController.swift
//  Gpx Import
//
//  Created by Matthew Goacher on 2/18/25.
//

import UIKit
import UniformTypeIdentifiers
import SwiftUI
import FoundationSalt
import os
let logger = Logger(subsystem: "com.saltily.Crwx.Gpx-Import", category: "Debug")

extension UTType {
    static var gpx: UTType {
        UTType(importedAs: "com.topografix.gpx", conformingTo: xml)
    }
    static var nob: UTType {
        UTType(importedAs: "com.rosepoint.nob", conformingTo: xml)
    }
}

class ShareViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            // Ensure access to extensionItem and itemProvider
            let itemProviders = extensionContext?.inputItems.compactMap {
                $0 as? NSExtensionItem
            }.flatMap {
                $0.attachments ?? []
            }.filter {
                $0.hasItemConformingToTypeIdentifier(UTType.gpx.identifier) ||
                $0.hasItemConformingToTypeIdentifier(UTType.nob.identifier) ||
                $0.hasItemConformingToTypeIdentifier(UTType.xml.identifier)
            } ?? []
            guard !itemProviders.isEmpty else { throw ShareError.InvalidType }
//            logger.info("Found \(itemProviders.count) matching item providers.")
//            guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
//                  let itemProvider = extensionItem.attachments?.first
//            else { throw ShareError.NoAccess }
//            guard itemProvider.hasItemConformingToTypeIdentifier(UTType.gpx.identifier)
//            else { throw ShareError.InvalidType }
            
            try load(itemProviders)
            
        } catch {
            logger.critical("Closing the share extension: \(error)")
            close()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
            DispatchQueue.main.async {
                self.close()
            }
        }
    }
    
    /// Close the Share Extension
    func close() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    /// Because NSItemProvider is pre-sendable, move our call to that into a nonisolated function to supress compilation warning.
    nonisolated func load(_ itemProviders: [NSItemProvider]) throws {
        Task {
            guard let container = URL.appGroupContainer
            else { throw ShareError.MissingGroupContainer }
            for provider in itemProviders {
                if let url = try? await provider.loadItem(forTypeIdentifier: UTType.gpx.identifier) as? URL {
                    let data = try Data(contentsOf: url)
                    let newLocation = container.appendingPathComponent(url.lastPathComponent, conformingTo: .gpx)
                    try data.write(to: newLocation)
                } else if let url = try? await provider.loadItem(forTypeIdentifier: UTType.nob.identifier) as? URL {
                    let data = try Data(contentsOf: url)
                    let newLocation = container.appendingPathComponent(url.lastPathComponent, conformingTo: .nob)
                    try data.write(to: newLocation)
                } else if let url = try? await provider.loadItem(forTypeIdentifier: UTType.xml.identifier) as? URL {
                    let data = try Data(contentsOf: url)
                    let newLocation = container.appendingPathComponent(url.lastPathComponent, conformingTo: .xml)
                    try data.write(to: newLocation)
                } else {
                    throw ShareError.NoURL
                }
            }
//            guard let url = try await itemProvider.loadItem(forTypeIdentifier: UTType.gpx.identifier) as? URL
//            else { throw ShareError.NoURL }
            
            // just send this url to the app
            await MainActor.run {
//                saveURLString(url.absoluteString)
                openMainApp()
            }
            
//            let data = try Data(contentsOf: url)
//            
//            // host the SwiftUI view
//            await MainActor.run {
//                let contentView = UIHostingController(rootView: ShareView(gpxData: data))
//                self.addChild(contentView)
//                self.view.addSubview(contentView.view)
//                
//                // set up constraints
//                contentView.view.translatesAutoresizingMaskIntoConstraints = false
//                contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
//                contentView.view.bottomAnchor.constraint (equalTo: self.view.bottomAnchor).isActive = true
//                contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
//                contentView.view.rightAnchor.constraint (equalTo: self.view.rightAnchor).isActive = true
//            }
        }
    }
    
//    private func saveURLString(_ urlString: String) {
//        let defaults = UserDefaults(suiteName: .appGroupKey)
//        logger.trace("The defaults are \(describing(defaults))")
//        UserDefaults(suiteName: .appGroupKey)?.set(urlString, forKey: .shareFileUrlKey)
//        let string = defaults?.value(forKey: .shareFileUrlKey)
//        logger.trace("The value is \(describing(string))")
//        let url = URL(string: string as? String)
//        logger.trace("The url is \(describing(url))")
//    }
    private func openMainApp() {
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: { _ in
            Task {
                if await self.openURL(.receiveGpx) {
                    logger.info("We should have opened the url")
                } else {
                    logger.warning("Why couldn't we open the url?")
                }
            }
        })
    }
    @objc func openURL(_ url: URL) async -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                logger.info("And we found the application to open the url")
                return await application.open(url)
            }
            responder = responder?.next
        }
        return false
    }
    
}

enum ShareError: Error {
    case NoAccess
    case InvalidType
    case NoURL
    case MissingGroupContainer
}

extension URL {
    public static var appGroupContainer: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: .appGroupKey)
    }
    public static let receiveGpx = URL(string: "crwx://receive-gpx")!
}
extension String {
    public static let appGroupKey = "group.com.saltily.Mewx"
    public static let cloudKitKey = "iCloud.com.saltily.Mewx"
}
