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

    func loadPDFText(file: File)  {
        do {
            guard let documentURL = file.fullURL else { throw "Document URL not found for file: \(file.name).pdf" }
            guard let document = PDFDocument(url: documentURL) else { throw "Failed to load PDF document." }
            let currentPage = file.currentPage < document.pageCount ? file.currentPage : 0
            guard let page = document.page(at: currentPage) else { throw "Failed to load page." }
            guard let pageText = page.string else { throw "No text found on this page." }
            guard !pageText.isEmpty else { throw "No text found on this page." }
            DispatchQueue.main.async {
                self.pdfText = pageText.replacingOccurrences(of: "\n", with: " ")
                debugPrint(pageText)
                print(page.attributedString)
            }
        } catch let error {
            print(error)
        }
        DispatchQueue.main.async {
            self.loading = false
        }
    }
}
