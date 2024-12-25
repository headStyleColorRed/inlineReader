import Foundation
import SwiftData
import SwiftUI

@Model
final class Settings {
    var languageOfTranslation: Language
    var fontSize: Double
    var textAlignment: TextAlignment
    var startAtPage: Int = 0

    init(languageOfTranslation: Language = .english,
         fontSize: Double = 16.0,
         textAlignment: TextAlignment = .left) {
        self.languageOfTranslation = languageOfTranslation
        self.fontSize = fontSize
        self.textAlignment = textAlignment
    }
}

enum TextAlignment: String, Codable {
    case left
    case right

    var appleAlignment: NSTextAlignment {
        switch self {
        case .left:
            return .left
        case .right:
            return .right
        }
    }
}
