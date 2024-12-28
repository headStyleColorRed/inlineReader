import SwiftUI
import PDFKit

class PDFReaderViewModel: ObservableObject {
    @Published var loading = true
    @Published var pdfText: String = ""

    private let openAIService = OpenAIService(apiKey: Configuration.openAIApiKey)

    init() { }

    func changePage(by: Int, file: File) {
        loading = true
        pdfText.removeAll()
        file.currentPage += by
        Task {
            await loadPDFText(file: file)
        }
    }

    func loadPDFText(file: File) async {
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
                self.pdfText = fullText
            }
        } catch let error {
            print(error)
        }
        DispatchQueue.main.async {
            self.loading = false
        }
    }
}
