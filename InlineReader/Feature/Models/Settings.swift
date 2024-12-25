import Foundation
import SwiftData

@Model
final class Settings {
    var languageOfTranslation: Language
    var fontSize: Double
    var textAlignment: TextAlignment

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
}
