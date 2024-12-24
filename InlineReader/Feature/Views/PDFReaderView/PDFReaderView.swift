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

struct SelectedText: Identifiable {
    let id: UUID
    let text: String

    init(text: String) {
        self.id = UUID()
        self.text = text
    }
}

// Custom UIViewRepresentable to integrate PDFKit with SwiftUI
struct PDFKitRepresentedView: View {
    let file: File
    @State private var pdfText: String = ""
    @State private var selectedText: SelectedText? = nil

    var body: some View {
        HStack {
            SelectableTextView(text: pdfText, onTextSelected: { text in
                print("Text selected")
                selectedText = SelectedText(text: text)
            })
            .defersSystemGestures(on: .all)
            .padding(EdgeInsets(top: 20, leading: 200, bottom: 20, trailing: 200))
            .onAppear {
                loadPDFText()
            }
        }
        .sheet(item: $selectedText) { text in
            NavigationStack {
                TranslationView(text: text)
            }
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
    PDFReaderView(file: File(url: URL(fileURLWithPath: "test.pdf")))
        .modelContainer(for: File.self, inMemory: true)
}


struct SelectableTextView: UIViewRepresentable {
    let text: String
    var onTextSelected: ((String) -> Void)?

    func makeUIView(context: Context) -> CustomTextView {
        let textView = CustomTextView(frame: .zero)
        textView.isEditable = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.textColor = UIColor.white
        textView.onTextSelected = onTextSelected
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainer.lineFragmentPadding = 8
        textView.textContainer.lineBreakMode = .byWordWrapping

        // Set the line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10 // Adjust the line spacing as needed

        // Ensure the text color is set in the attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white // Ensure text color is set
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        textView.attributedText = attributedString

        return textView
    }

    func updateUIView(_ uiView: CustomTextView, context: Context) {
        // Update the attributed text with line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10 // Ensure the line spacing is consistent

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white // Ensure text color is set
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        uiView.attributedText = attributedString
        uiView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

class CustomTextView: UITextView, UIEditMenuInteractionDelegate {
    var onTextSelected: ((String) -> Void)?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupEditMenuInteraction()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupEditMenuInteraction()
    }

    private func setupEditMenuInteraction() {
        let interaction = UIEditMenuInteraction(delegate: self)
        self.addInteraction(interaction)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    // Enable custom actions
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(customCopy(_:)) || action == #selector(translate(_:)) {
            return true
        }
        return false
    }

    // Custom copy action
    @objc func customCopy(_ sender: Any?) {
        print("Starting custom copy action")
        UIPasteboard.general.string = self.text
        print("Custom copy action performed. Copied text: \(String(describing: self.text))")
    }

    // Custom chat action
    @objc func translate(_ sender: Any?) {
        print("Starting translate action")
        if let selectedRange = self.selectedTextRange, let selectedText = self.text(in: selectedRange) {
            onTextSelected?(selectedText)
        }
        // Implement your chat functionality here
        print("Translate action performed.")
    }

    override func editMenu(for textRange: UITextRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        print("Creating edit menu for text range: \(textRange)")
        let customCopyAction = UIAction(title: "Copy", image: nil) { _ in
            print("Copy action selected from menu")
            self.customCopy(nil)
        }

        let chatAction = UIAction(title: "Translate", image: nil) { _ in
            print("Translate action selected from menu")
            self.translate(nil)
        }
        return UIMenu(children: [customCopyAction, chatAction])
    }
}
