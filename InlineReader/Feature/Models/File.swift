//
//  File.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import Foundation
import SwiftData

@Model
final class File: CustomStringConvertible, Equatable {
    var id: UUID
    var name: String
    var progress: Int
    var dateAdded: Date
    var lastOpened: Date?
    private var url: String

    init(url: URL) {
        self.id = UUID()
        self.progress = 0
        self.dateAdded = Date()
        self.lastOpened = nil
        // The url Will only be the last path component since we are in the documents directory
        self.url = url.lastPathComponent
        // The name will be the last path component without the extension
        self.name = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
    }

    func updateLastOpened() {
        self.lastOpened = Date()
    }

    var description: String {
        return """
        {
            name: \(name),
            url: \(url),
            progress: \(progress),
            dateAdded: \(dateAdded),
            lastOpened: \(lastOpened?.asStringWith(format: .userFacingOnlyDate) ?? "Never opened")
        }
        """
    }

    static func == (lhs: File, rhs: File) -> Bool {
        return lhs.url == rhs.url
    }
}

// MARK: - File operations
extension File {
    var fullURL: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(url)
    }
}
