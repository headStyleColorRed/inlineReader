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
struct PDFKitRepresentedView: UIViewRepresentable {
    let file: File

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        let fileNameWithoutExtension = (file.name as NSString).deletingPathExtension
        print("Attempting to load file: \(fileNameWithoutExtension).pdf")
        if let documentURL = Bundle.main.url(forResource: fileNameWithoutExtension, withExtension: "pdf") {
            print("Document URL: \(documentURL)")
            if let document = PDFDocument(url: documentURL) {
                pdfView.document = document
            } else {
                print("Failed to load PDF document.")
            }
        } else {
            print("Document URL not found for file: \(fileNameWithoutExtension).pdf")
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update the view if needed
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
        .modelContainer(for: File.self, inMemory: true)
}
