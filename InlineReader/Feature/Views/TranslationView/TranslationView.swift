//
//  TranslationView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 24/12/24.
//

import SwiftUI

struct TranslationView: View {
    @StateObject var viewModel: TranslationViewModel

    init(text: SelectedText, settings: Settings) {
        _viewModel = StateObject(wrappedValue: TranslationViewModel(text: text, settings: settings))
    }

    var alignment: Alignment {
        viewModel.settings.textAlignment == .left ? .leading : .trailing
    }

    var body: some View {
        ScrollView {
            VStack(alignment: alignment == .leading ? .leading : .trailing, spacing: 16) {
                Text("Translated Text")
                    .font(.title2)
                    .padding(.vertical)
                    .multilineTextAlignment(.center)

                VStack(alignment: .trailing, spacing: 8) {
                    Text(viewModel.textToTranslate)
                        .font(.body)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: alignment)
                        .padding(.horizontal)

                    if viewModel.isLoading {
                        loadingView()
                    } else {
                        Text(viewModel.translatedText)
                            .font(.body)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: alignment)
                            .padding(.horizontal)
                    }
                }

                if viewModel.isFurtherTranslating {
                    loadingView()
                } else {
                    Text(viewModel.furtherTranslatedText)
                        .font(.body)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: alignment)
                        .padding(.top, 20)
                        .padding(.horizontal)
                }

                Button("Translate") {
                    Task {
                        await viewModel.startTranslation()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)

                Button("Further Translate") {
                    Task {
                        await viewModel.furtherTranslate()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)

                Spacer()
            }
            .padding()
        }
    }

    func loadingView() -> some View {
        ProgressView()
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
}

struct TempView: View {
    @State var isPresented = true

    var body: some View {
        Button("Translate usted") {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            TranslationView(
                text: SelectedText(text: "שלום לכולם"),
                settings: Settings(languageOfTranslation: .amharic, fontSize: 17, textAlignment: .left)
            )
        }
    }
}

#Preview {
    VStack {
        TempView()
    }
}
