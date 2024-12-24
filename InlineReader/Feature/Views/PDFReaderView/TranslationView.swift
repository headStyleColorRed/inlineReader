//
//  TranslationView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 24/12/24.
//

import SwiftUI

class TranslationViewModel: ObservableObject {
    @Published var translatedText: String = ""

    init(text: SelectedText) {
        self.translatedText = text.text
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

                VStack {
                    Text(viewModel.translatedText) // Use viewModel.translatedText
                        .font(.subheadline)
                    Text(viewModel.translatedText) // Use viewModel.translatedText
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                startTranslation()
            }
        }
    }

    private func startTranslation() {
        print("translating text: \(viewModel.translatedText)")
    }
}


#Preview {
    TranslationView(text: SelectedText(text: "Hello, World!"))
}
