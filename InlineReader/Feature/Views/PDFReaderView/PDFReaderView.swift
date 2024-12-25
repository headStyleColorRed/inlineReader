import SwiftUI
import PDFKit

struct PDFReaderView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @StateObject private var viewModel = PDFReaderViewModel()
    @State private var pdfText: String = ""
    @State private var selectedText: SelectedText? = nil

    private let file: File

    init(file: File) {
        self.file = file
    }

    private var padding: CGFloat {
        mainViewModel.columnVisibility == .detailOnly ? 200 : 50
    }

    var body: some View {
        HStack {
            SelectableTextView(text: pdfText, onTextSelected: { text in
                print("Text selected")
                selectedText = SelectedText(text: text)
            })
            .defersSystemGestures(on: .all)
            .padding(EdgeInsets(top: 20, leading: padding, bottom: 20, trailing: padding))
            .onAppear {
                loadPDFText()
            }
        }
        .withLoader(loading: $viewModel.loading)
        .sheet(item: $selectedText) { text in
            NavigationStack {
                TranslationView(text: text)
            }
        }
        .onAppear {
            mainViewModel.columnVisibility = .detailOnly
        }
        .onDisappear {
            mainViewModel.columnVisibility = .all
        }
        .navigationTitle(file.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadPDFText() {
        guard let documentURL = file.fullURL else {
            print("Document URL not found for file: \(file.name).pdf")
            pdfText = "Document URL not found."
            return
        }

        print("Document URL: \(documentURL)")
        if let document = PDFDocument(url: documentURL) {
            var fullText = ""
            for pageIndex in 0..<document.pageCount {
                if let page = document.page(at: pageIndex) {
                    if let pageText = page.string {
                        fullText += pageText
                    }
                }
            }
            pdfText = fullText.isEmpty ? "No text found in PDF." : fullText
            print("PDF text loaded successfully.")
        } else {
            print("Failed to load PDF document.")
            pdfText = "Failed to load PDF document."
        }
    }
}

#Preview(traits: .landscapeLeft) {
    PDFReaderView(file: File(url: URL(fileURLWithPath: "test.pdf")))
        .modelContainer(for: File.self, inMemory: true)
}
