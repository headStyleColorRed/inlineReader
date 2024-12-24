//
//  TranslationView.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 24/12/24.
//

import SwiftUI

struct TranslationView: View {
    let text: SelectedText

    init(text: SelectedText) {
        self.text = text
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Translated Text")
                    .font(.headline)
                    .padding()
                    .fullWidthExpanded()

                VStack {
                    Text(text.text) // Original selected text
                        .font(.subheadline)
                    Text(text.text) // Original selected text
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
        print("translating  text: \(text.text)")
    }
}


#Preview {
    TranslationView(text: SelectedText(text: "Hello, World!"))
}
