import SwiftUI

class TextReaderViewModel: ObservableObject {
    @Published var loading = true
    @Published var text: String = ""

    private let openAIService = OpenAIService(apiKey: Configuration.openAIApiKey)

    init() { }

    func loadText(file: File) async {
        do {
            guard let documentURL = file.fullURL else {
                throw "Document URL not found for file: \(file.name).txt"
            }

            let fileContents = try String(contentsOf: documentURL, encoding: .utf8)
            guard !fileContents.isEmpty else {
                throw "No text found in this file."
            }

            DispatchQueue.main.async {
                self.text = fileContents
            }
        } catch let error {
            print(error)
        }
        DispatchQueue.main.async {
            self.loading = false
        }
    }
}
