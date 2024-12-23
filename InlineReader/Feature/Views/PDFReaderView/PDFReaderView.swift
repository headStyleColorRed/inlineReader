import SwiftUI
import PDFKit

struct PDFReaderView: View {
    let file: File

    var body: some View {
        PDFKitRepresentedView(file: file)
            .navigationTitle(file.name)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// Custom UIViewRepresentable to integrate PDFKit with SwiftUI
struct PDFKitRepresentedView: View {
    let file: File
    @State private var pdfText: String = ""

    var body: some View {
        SelectableTextView(text: pdfText)
            .defersSystemGestures(on: .all)
            .padding()
        .onAppear {
            loadPDFText()
        }
    }

    private func loadPDFText() {
        let fileNameWithoutExtension = (file.name as NSString).deletingPathExtension
        print("Attempting to load file: \(fileNameWithoutExtension).pdf")
        if let documentURL = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: "pdf") {
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
                print("PDF text: \(pdfText)")
            } else {
                print("Failed to load PDF document.")
                pdfText = "Failed to load PDF document."
            }
        } else {
            print("Document URL not found for file: \(fileNameWithoutExtension).pdf")
            pdfText = "Document URL not found."
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
        .modelContainer(for: File.self, inMemory: true)
}


struct SelectableTextView: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(frame: .zero)
        textView.text = text
        print("Creating UITextView with text: \(text)")
        textView.isEditable = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor.lightGray
        textView.textColor = UIColor.black
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        print("Updating UITextView with text: \(text)")
        uiView.text = text
        uiView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}
