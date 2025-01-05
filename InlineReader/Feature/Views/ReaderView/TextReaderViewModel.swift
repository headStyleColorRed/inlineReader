import SwiftUI

class TextReaderViewModel: ObservableObject {
    @Published var text: NSAttributedString = NSAttributedString(string: "")

    let file: File

    init(file: File) {
        self.file = file
    }

    // MARK: - Public methods
    func viewDidLoad() {
        loadText(file: file)
    }


    // MARK: - Private methods
    private func loadText(file: File) {
        do {
            guard let documentURL = file.fullURL else { throw "Document URL not found for file: \(file.name).txt" }

            let fileContents = try String(contentsOf: documentURL, encoding: .utf8)
            guard !fileContents.isEmpty else { throw "No text found in this file." }

            DispatchQueue.main.async {
                self.text = NSAttributedString(string: fileContents)
            }
        } catch let error {
            BannerManager.showError(message: error.localizedDescription)
        }
    }
}
