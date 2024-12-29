import UIKit
class CustomTextView: UITextView, UIEditMenuInteractionDelegate {
    var selectionActions: SelectionActions?
    var annotations: [Annotation] = []

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


        // Annotations
        let annotation = annotationFor(range: self.selectedTextRange)
        let annotationTitle = annotation != nil ? "Remove Annotation" : "Annotate"

        let annotateAction = UIAction(title: annotationTitle, image: nil) { _ in
            print("Annotate action selected from menu")
            if let annotation {
                self.selectionActions?.onRemoveAnnotation(annotation)
            } else {
                self.annotate(nil)
            }
        }

        return UIMenu(children: [customCopyAction, chatAction, annotateAction])
    }

    func annotationFor(range: UITextRange?) -> Annotation? {
        guard let range else { return nil }

        let selectedRange = NSRange(location: offset(from: beginningOfDocument, to: range.start),
                              length: offset(from: range.start, to: range.end))
        print("selected range: \(selectedRange)")

        for annotation in annotations {
            print("Annotation range: \(annotation.range)")
            if rangesCollide(annotation.range, selectedRange) {
                return annotation
            }
        }
        return nil
    }

    func rangesCollide(_ range1: NSRange, _ range2: NSRange) -> Bool {
        let start1 = range1.location
        let end1 = start1 + range1.length
        let start2 = range2.location
        let end2 = start2 + range2.length

        // Check if one range starts before the other ends
        return start1 < end2 && start2 < end1
    }
}

struct SelectionActions {
    var onTranslate: (String) -> Void
    var onAnnotate: (String, NSRange) -> Void
    var onRemoveAnnotation: (Annotation) -> Void
}
