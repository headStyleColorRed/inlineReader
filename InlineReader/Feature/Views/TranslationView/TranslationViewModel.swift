//
//  TranslationViewModel.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 25/12/24.
//

import Foundation
import SwiftUI

class TranslationViewModel: ObservableObject {
    @Published var translatedText: String = ""
    @Published var textToTranslate: String = ""
    @Published var isLoading: Bool = false
    private let openAIService: OpenAIService

    init(text: SelectedText) {
        self.textToTranslate = text.text
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
}
