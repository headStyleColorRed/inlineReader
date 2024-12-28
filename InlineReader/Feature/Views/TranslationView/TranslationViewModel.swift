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
    @Published var isLoading: Bool = false
    @Published var isFurtherTranslating: Bool = false

    private let openAIService: OpenAIService
    let settings: Settings

    init(text: SelectedText, settings: Settings) {
        self.textToTranslate = text.text
        self.settings = settings
        self.openAIService = OpenAIService(apiKey: Configuration.openAIApiKey)
    }

    @MainActor
    func startTranslation() async {
        isLoading = true
        do {
            translatedText = try await openAIService.translate(textToTranslate)
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
            let translatedText = try await openAIService.furtherTranslate(textToTranslate)

            // Add an extra newline where there's a newline followed by a number
            let formattedText = translatedText.replacingOccurrences(of: "\n(?=\\d)", with: "\n\n", options: .regularExpression)

            // Set the text to translate to the translated text
            furtherTranslatedText = formattedText
        } catch {
            furtherTranslatedText = "Further translation failed: \(error.localizedDescription)"
        }
        isFurtherTranslating = false
    }
}
