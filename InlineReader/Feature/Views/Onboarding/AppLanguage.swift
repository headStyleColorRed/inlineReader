import SwiftUI

enum AppLanguage: String, CaseIterable {
    case english = "English"
    case russian = "Русский"
    case spanish = "Español"
    case french = "Français"

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .russian: return "🇷🇺"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        }
    }
}
