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
            VStack(spacing: 16) {
                Text("Translated Text")
                    .font(.title2)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, alignment: .center)


                Text(viewModel.textToTranslate)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: alignment)
                    .multilineTextAlignment(alignment == .leading ? .leading : .trailing)
                    .padding()


                Divider()

                if viewModel.isLoading {
                    loadingView()
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(viewModel.translatedText)
                        .font(.body)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                }

                Text(". . .")
                    .font(.body)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
                    .isHidden(viewModel.isLoading || !viewModel.hasTranslated, remove: true)


                if viewModel.isFurtherTranslating {
                    loadingView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text(viewModel.furtherTranslatedText)
                        .font(.body)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 10)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .task {
                await viewModel.startTranslation()
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    Task {
                        await viewModel.furtherTranslate()
                    }
                }) {
                    Text("Show examples...")
                        .font(.body)
                        .padding(10)
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .isHidden(hideFurtherTranslationButton, remove: true)
            }
        }
    }

    var hideFurtherTranslationButton: Bool {
        viewModel.hasFurtherTranslated ||
        viewModel.isLoading ||
        viewModel.isFurtherTranslating ||
        viewModel.textToTranslate.wordCount > 10
    }

    func loadingView() -> some View {
        ProgressView()
            .padding(.horizontal)
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
                settings: Settings(languageOfTranslation: .amharic, fontSize: 17, textAlignment: .right)
            )
        }
    }
}

#Preview {
    VStack {
        TempView()
    }
}
