import SwiftUI
import SwiftData
import NaturalLanguage

struct PDFReaderSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var file: File

    @State private var languageOfTranslation: Language
    @State private var fontSize: Double
    @State private var textAlignment: TextAlignment

    init(file: File) {
        self.file = file
        _languageOfTranslation = State(initialValue: file.settings.languageOfTranslation)
        _fontSize = State(initialValue: file.settings.fontSize)
        _textAlignment = State(initialValue: file.settings.textAlignment)
    }

    var body: some View {
        Form {
            Section("Translation") {
                Picker("Language of Translation", selection: $languageOfTranslation) {
                    ForEach(Language.allCases, id: \.self) { language in
                        Text(language.rawValue.capitalized).tag(language)
                    }
                }
            }

            Section("Text Settings") {
                HStack {
                    Text("Font Size")
                    Spacer()
                    Slider(value: $fontSize, in: 8...32, step: 1.0)
                    Text("\(fontSize, specifier: "%.0f")")
                }

                Picker("Text Alignment", selection: $textAlignment) {
                    Text("Left to Right").tag(TextAlignment.left)
                    Text("Right to Left").tag(TextAlignment.right)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    file.settings.languageOfTranslation = languageOfTranslation
                    file.settings.fontSize = fontSize
                    file.settings.textAlignment = textAlignment
                    dismiss()
                }
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    PDFReaderSettingsView(file: File(url: URL(string: "Documents/%D7%99%D7%9C%D7%93%D7%94%20%D7%A7%D7%98%D7%A0%D7%94%20%D7%95%D7%97%D7%91%D7%A8%20%D7%97%D7%93%D7%A9.pdf")!))
}
