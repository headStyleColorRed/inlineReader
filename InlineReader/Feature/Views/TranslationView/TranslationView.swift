//
//  TranslationView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 24/12/24.
//

import SwiftUI

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
