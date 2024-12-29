//
//  File.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import Foundation
import SwiftData
import UniformTypeIdentifiers

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

    var fileType: UTType {
        guard let url = fullURL else { return .item }
        let components = url.pathExtension.split(separator: ".")
        guard let lastComponent = components.last?.lowercased() else { return .item }

        switch lastComponent {
        case "pdf": return .pdf
        case "txt": return .text
        default: return .item
        }
    }

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
    private var _location: Int
    private var _range: Int

    var range: NSRange {
        return NSRange(location: _location, length: _range)
    }

    init(text: String, range: NSRange) {
        self.text = text
        self._location = range.location
        self._range = range.length
    }
}
