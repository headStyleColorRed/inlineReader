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
    @State private var showSideView: Bool = false
    @State private var selectedText: String = ""

    var body: some View {
        HStack {
            SelectableTextView(text: pdfText, onTextSelected: { text in
                print("Text selected")
                selectedText = text
                toggleSideView()
            })
            .defersSystemGestures(on: .all)
            .padding()
            .onAppear {
                loadPDFText()
            }

            if showSideView {
                VStack {
                    Text("Translation")
                        .font(.headline)
                        .padding()
                    Text(selectedText)
                        .padding()
                    Spacer()
                }
                .frame(width: 300)
                .background(Color.white)
                .foregroundColor(Color.black)
                .shadow(radius: 5)
                .transition(.move(edge: .trailing))
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

    private func toggleSideView() {
        withAnimation {
            showSideView.toggle()
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
        .modelContainer(for: File.self, inMemory: true)
}


struct SelectableTextView: UIViewRepresentable {
    let text: String
    var onTextSelected: ((String) -> Void)?

    func makeUIView(context: Context) -> CustomTextView {
        let textView = CustomTextView(frame: .zero)
        textView.text = text
        textView.isEditable = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.textColor = UIColor.white
        textView.onTextSelected = onTextSelected

        return textView
    }

    func updateUIView(_ uiView: CustomTextView, context: Context) {
        uiView.text = text
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
