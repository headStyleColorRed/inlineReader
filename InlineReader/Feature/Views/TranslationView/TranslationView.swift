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
            VStack(alignment: alignment == .leading ? .leading : .trailing) {
                Text("Translated Text")
                    .font(.headline)
                    .padding(.vertical)
                    .multilineTextAlignment(.center)

                VStack(alignment: .trailing) {

                    Text(viewModel.textToTranslate)
                        .font(.subheadline)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, alignment: alignment)


                    if viewModel.isLoading {
                        loadingView()
                    } else {
                        Text(viewModel.translatedText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: alignment)
                    }
                }

                if viewModel.isFurtherTranslating {
                    loadingView()
                } else {
                    Text(viewModel.furtherTranslatedText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: alignment)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: alignment)
                }

                Button("Translate") {
                    Task {
                        await viewModel.startTranslation()
                    }
                }
                .padding(.top, 20)
                Button("Further Translate") {
                    Task {
                        await viewModel.furtherTranslate()
                    }
                }
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
