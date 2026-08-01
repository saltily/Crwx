//
//  ImportPackableItemDefinitionsButton.swift
//  Crwx
//
//  Created by Matthew Goacher on 8/1/26.
//

import SwiftUI
import FoundationSalt
import CodableSalt

struct ImportPackableItemDefinitionsButton: View {
    var body: some View {
        Button("Import Packable Items", systemImage: "square.and.arrow.down") {
            
            do {
                // 1. Get tsv text from the pasteboard.
                guard let tsvText = Pasteboard.general.string
                else { throw E.PasteboardEmpty }
                
                // 2. Parse into definitions.
                let definitions: [PackableItemDefinition] = try .init(tsv: tsvText)
                
                // 3. Encode for swift hardcoding.
                let output = """
                extension PackableItemDefinition {
                    static var allCases: [PackableItemDefinition] {
                        [
                            \(definitions.map(\.nameRender).joined(separator: ", "))
                        ]
                    }
                \(definitions.map(\.swiftRender).joined(separator: "\n"))
                }
                """
                
                // 5. Include some stats about how many items and when.
                let stats = """
                /// \(definitions.count.appending("item", "items"))
                /// Imported \(Date.now.formatted(.dateTime))
                """
                
                // 6. Put it back on the pasteboard.
                Pasteboard.general.string = "\(stats)\n\(output)"
                
            } catch {
                
                // 5b. Put error stats on pasteboard.
                Pasteboard.general.string = "// Couldn't import packable items from pasteboard:\n//   \(error)"
                
            }
            
        }
        .disabled(!Pasteboard.general.hasStrings)
    }
    enum E: Error {
        case PasteboardEmpty
    }
}

#Preview {
    ImportPackableItemDefinitionsButton()
}

extension PackableItemDefinition {
    fileprivate var nameCamelCase: String {
        if name == "5200" {
            return "fiftyTwoHundred"
        }
        var words = name.capitalized.words
        words[0] = words[0].lowercased()
        return words.joined(separator: "")
    }
    fileprivate var nameRender: String {
        ".\(nameCamelCase)"
    }
    fileprivate var consumableRender: String {
        guard let consumable else { return "nil" }
        return ".\(consumable.rawValue)"
    }
    fileprivate var swiftRender: String {
        """
            static var \(nameCamelCase): PackableItemDefinition {
                .init(id: UUID(uuidString: "\(id.uuidString)")!, name: "\(name)", category: .\(category.rawValue), lifecycle: .\(lifecycle.rawValue), consumable: \(consumableRender), locker: .\(locker.rawValue), requiresDockside: \(requiresDockside ? "true" : "false"))
            }
        """
    }
}
