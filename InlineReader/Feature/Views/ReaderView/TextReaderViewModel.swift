import SwiftUI
import PDFKit

class TextReaderViewModel: ObservableObject {
    @Published var text: NSAttributedString = NSAttributedString(string: "")

    let file: File

    init(file: File) {
        self.file = file
    }

    // MARK: - Public methods
    func viewDidLoad() {
        print("file type: \(file.fileType)")
        switch file.fileType {
        case .text:
            loadText(file: file)
        case .pdf:
            loadPDFText(file: file)
        default:
            break
        }
    }


    // MARK: - Private methods
    func loadText(file: File) {
        do {
            guard let documentURL = file.fullURL else { throw "Document URL not found for file: \(file.name).txt" }

            let fileContents = try String(contentsOf: documentURL, encoding: .utf8)
            guard !fileContents.isEmpty else { throw "No text found in this file." }

            DispatchQueue.main.async {
                self.text = NSAttributedString(string: fileContents)
            }
        } catch let error {
            print(error)
        }
    }

    func loadPDFText(file: File) {
        do {
            guard let documentURL = file.fullURL else { throw "Document URL not found for file: \(file.name).pdf" }
            guard let document = PDFDocument(url: documentURL) else { throw "Failed to load PDF document." }

            // Convert entire PDF to text
            var fullText = ""
            for pageIndex in 0..<document.pageCount {
                guard let page = document.page(at: pageIndex) else { continue }
                if let pageText = page.string {
                    fullText += pageText + "\n\n"
                }
            }

            guard !fullText.isEmpty else { throw "No text found in this document." }

            DispatchQueue.main.async {
                self.text = NSAttributedString(string: fullText)
            }
        } catch let error {
            print(error)
        }
    }
}
