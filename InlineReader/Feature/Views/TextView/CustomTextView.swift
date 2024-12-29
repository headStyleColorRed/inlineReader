import UIKit

class CustomTextView: UITextView, UIEditMenuInteractionDelegate {
    var selectionActions: SelectionActions?

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
        if action == #selector(customCopy(_:)) || action == #selector(translate(_:)) || action == #selector(annotate(_:)) {
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
            selectionActions?.onTranslate(selectedText)
        }
        // Implement your chat functionality here
        print("Translate action performed.")
    }

    // Annotation action
    @objc func annotate(_ sender: Any?) {
        let range = self.selectedRange
        let textRange = self.selectedTextRange
        print("1. Annotating text in range: \(range), text range: \(String(describing: textRange))")
        // Get current attributed text
        let attributedText = NSMutableAttributedString(attributedString: self.attributedText)
        // Add a yellow background color to the selected range
        attributedText.addAttribute(.backgroundColor, value: UIColor.yellow, range: self.selectedRange)
        // Set the attributed text back to the text view
        self.attributedText = attributedText
        // Pass the selected text and range to the selectionActions closure
        if let rangeToAnnotate = textRange, let selectedText = self.text(in: rangeToAnnotate) {
            print("2. Annotating text: \(selectedText) in range: \(range)")
            selectionActions?.onAnnotate(selectedText, range)
        }
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

        let annotateAction = UIAction(title: "Annotate", image: nil) { _ in
            print("Annotate action selected from menu")
            self.annotate(nil)
        }

        return UIMenu(children: [customCopyAction, chatAction, annotateAction])
    }
}

struct SelectionActions {
    var onTranslate: (String) -> Void
    var onAnnotate: (String, NSRange) -> Void
}
