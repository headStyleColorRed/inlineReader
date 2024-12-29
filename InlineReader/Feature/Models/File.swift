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
    var currentPage: Int
    private var url: String
    var settings: Settings
    var annotations: [Annotation] = []

    init(url: URL) {
        self.id = UUID()
        self.progress = 0
        self.dateAdded = Date()
        self.currentPage = 0
        // The url Will only be the last path component since we are in the documents directory
        self.url = url.lastPathComponent
        // The name will be the last path component without the extension
        self.name = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
        self.settings = Settings()
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
            lastOpened: \(lastOpened?.asStringWith(format: .userFacingOnlyDate) ?? "Never opened"),
            currentPage: \(currentPage)
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

@Model
class Annotation {
    var id = UUID()
    var text: String
    var range: NSRange

    init(text: String, range: NSRange) {
        self.text = text
        self.range = range
    }
}
