import SwiftUI
import SwiftData
import NaturalLanguage

struct PDFReaderSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var file: File

    var body: some View {
        Form {
            Section("Translation") {
                Picker("Language of Translation", selection: .init(
                    get: { Language(rawValue: file.settings?.languageOfTranslation ?? .undetermined) ?? .undetermined },
                    set: { file.settings?.languageOfTranslation = $0 }
                )) {
                    ForEach(Language.allCases, id: \.self) { language in
                        Text(language.rawValue.capitalized).tag(language)
                    }
                }
            }

            Section("Text Settings") {
                HStack {
                    Text("Font Size")
                    Spacer()
                    Slider(value: .init(
                        get: { file.settings?.fontSize ?? 16.0 },
                        set: { file.settings?.fontSize = $0 }
                    ), in: 8...32, step: 1.0)
                }

                Picker("Text Alignment", selection: .init(
                    get: { file.settings?.textAlignment ?? .left },
                    set: { file.settings?.textAlignment = $0 }
                )) {
                    Text("Left to Right").tag(TextAlignment.left)
                    Text("Right to Left").tag(TextAlignment.right)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview(traits: .landscapeLeft) {
    PDFReaderSettingsView(file: File(url: URL(string: "Documents/%D7%99%D7%9C%D7%93%D7%94%20%D7%A7%D7%98%D7%A0%D7%94%20%D7%95%D7%97%D7%91%D7%A8%20%D7%97%D7%93%D7%A9.pdf")!))
}
