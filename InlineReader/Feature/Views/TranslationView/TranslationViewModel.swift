//
//  TranslationViewModel.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 25/12/24.
//

import Foundation
import SwiftUI

class TranslationViewModel: ObservableObject {
    @Published var textToTranslate: String = ""
    @Published var translatedText: String = ""
    @Published var furtherTranslatedText: String = ""
    @Published var isLoading: Bool = true
    @Published var isFurtherTranslating: Bool = false

    @Published var hasTranslated: Bool = false
    @Published var hasFurtherTranslated: Bool = false

    private let openAIService: OpenAIService
    let settings: Settings

    var wordCount: Int {
        textToTranslate.split(whereSeparator: { $0.isWhitespace }).filter { !$0.isEmpty }.count
    }

    init(text: SelectedText, settings: Settings) {
        self.textToTranslate = text.lastSixtyWords
        self.settings = settings
        self.openAIService = OpenAIService(apiKey: Configuration.openAIApiKey)
    }

    @MainActor
    func startTranslation() async {
        do {
            translatedText = try await openAIService.translate(textToTranslate, language: settings.languageOfTranslation)
            hasTranslated = true
        } catch {
            translatedText = "Translation failed: \(error.localizedDescription)"
        }
        isLoading = false
    }

    @MainActor
    func furtherTranslate() async {
        isFurtherTranslating = true
        do {
            // Translate the text to English
            let translatedText = try await openAIService.furtherTranslate(textToTranslate, language: settings.languageOfTranslation)

            // Add an extra newline where there's a newline followed by a number
            let formattedText = translatedText.replacingOccurrences(of: "\n(?=\\d)", with: "\n\n", options: .regularExpression)

            // Set the text to translate to the translated text
            furtherTranslatedText = formattedText
            hasFurtherTranslated = true
        } catch {
            furtherTranslatedText = "Further translation failed: \(error.localizedDescription)"
        }
        isFurtherTranslating = false
    }
}
