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
    var name: String?
    var image: String?
    var progress: Int

    init(name: String?, image: String? = nil, progress: Int) {
        self.id = UUID()
        self.name = name
        self.image = image
        self.progress = progress
    }
}
