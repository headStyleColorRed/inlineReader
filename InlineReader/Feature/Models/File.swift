//
//  File.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import Foundation
import SwiftData
import UniformTypeIdentifiers
import PDFKit
import UIKit

@Model
final class File: CustomStringConvertible, Equatable, Mappable {
    // Local properties
    var localID: UUID?
    var dateAdded: Date = Date()
    var lastOpened: Date?
    var currentPage: Int = 0
    var settings = Settings()
    var annotations: [Annotation] = []
    var thumbnailData: Data?
    private var localUrl: String?

    // Common properties
    var name: String?

    // Server properties
    var serverId: String?
    var serverUrl: String?
    var blobId: String?
    var contentType: String?
    var byteSize: Int?
    var checksum: String?

    // Computed properties
    var fileType: UTType {
        guard let url = fullURL else { return .item }
        return url.fileType
    }
    var fullURL: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                                in: .userDomainMask).first,
              let localUrl else { return nil }
        return documentsDirectory.appendingPathComponent(localUrl)
    }
    var urlExtension: String {
        return fullURL?.pathExtension.components(separatedBy: ".").last ?? ""
    }

    // Local initialiser
    init(url: URL, thumbNail: Data? = nil) {
        self.localID = UUID()
        // The url Will only be the last path component since we are in the documents directory
        self.localUrl = url.lastPathComponent
        // The name will be the last path component without the extension
        self.name = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
        self.settings = Settings()
        self.thumbnailData = thumbNail
    }

    //Server initialiser
    init(from document: Document) {
        self.serverId = document.id
        self.serverUrl = document.url
        self.blobId = document.blobId
        self.contentType = document.contentType
        self.byteSize = document.byteSize
        self.checksum = document.checksum
    }

    // Mappable methods
    required init(map: Map) {}

    func mapping(map: Map) {
        serverId <- map["id"]
        serverUrl <- map["url"]
        blobId <- map["blobId"]
        contentType <- map["contentType"]
        byteSize <- map["byteSize"]
        checksum <- map["checksum"]
    }

    // Common methods
    func updateLastOpened() {
        self.lastOpened = Date()
    }

    func updateWith(document: Document) {
        self.serverId = document.id
        self.serverUrl = document.url
        self.blobId = document.blobId
        self.contentType = document.contentType
        self.byteSize = document.byteSize
        self.checksum = document.checksum
    }

    var description: String {
        return """
        {
            name: \(name ?? "Unknown"),
            serverId: \(serverId ?? "Unknown"),
            serverUrl: \(serverUrl ?? "Unknown"),
            blobId: \(blobId ?? "Unknown"),
            url: \(localUrl ?? "Unknown"),
        }
        """
    }

    static func == (lhs: File, rhs: File) -> Bool {
        return lhs.localUrl == rhs.localUrl
    }
}

extension URL {
    var fileType: UTType {
        let components = self.pathExtension.split(separator: ".")
        guard let lastComponent = components.last?.lowercased() else { return .item }

        switch lastComponent {
        case "pdf": return .pdf
        case "txt": return .text
        default: return .item
        }
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


import ObjectMapper
@Model
class Document: Mappable {
    var id: String?
    var name: String?
    var url: String?
    var blobId: String?
    var contentType: String?
    var byteSize: Int?
    var checksum: String?

    required init(map: Map) {}

    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        url <- map["url"]
        blobId <- map["blobId"]
        contentType <- map["contentType"]
        byteSize <- map["byteSize"]
        checksum <- map["checksum"]
    }
}
