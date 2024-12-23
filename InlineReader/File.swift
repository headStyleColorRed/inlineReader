//
//  File.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 23/12/24.
//

import Foundation
import SwiftData

@Model
final class File {
    var id: UUID
    var name: String
    var url: URL
    var progress: Int
    var dateAdded: Date

    init(url: URL) {
        self.id = UUID()
        self.name = url.lastPathComponent
        self.url = url
        self.progress = 0
        self.dateAdded = Date()
    }
}
