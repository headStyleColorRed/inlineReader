//
//  TranslationView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 24/12/24.
//

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

struct TranslationView: View {
    @StateObject var viewModel: TranslationViewModel

    init(text: SelectedText) {
        _viewModel = StateObject(wrappedValue: TranslationViewModel(text: text))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Translated Text")
                    .font(.headline)
                    .padding()
                    .fullWidthExpanded()

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    VStack {
                        Text(viewModel.textToTranslate)
                            .font(.subheadline)
                        Text(viewModel.translatedText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Button("Translate") {
                    Task {
                        await viewModel.startTranslation()
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    TranslationView(text: SelectedText(text: "Hola rodrigo"))
}
