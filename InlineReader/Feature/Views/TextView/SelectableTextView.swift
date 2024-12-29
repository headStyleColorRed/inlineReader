import SwiftUI

struct Constants {
    static let lightAnnotationColor: UIColor = .yellow
    static let darkAnnotationColor: UIColor = .orange
}

struct SelectableTextView: UIViewRepresentable {
    let text: NSAttributedString
    let options: Settings
    let annotations: [Annotation]
    let selectionActions: SelectionActions?

    init(text: NSAttributedString, options: Settings, annotations: [Annotation], selectionActions: SelectionActions? = nil) {
        self.text = text
        self.options = options
        self.annotations = annotations
        self.selectionActions = selectionActions
    }

    func makeUIView(context: Context) -> CustomTextView {
        let textView = CustomTextView(frame: .zero)
        textView.isEditable = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.selectionActions = selectionActions
        textView.font = UIFont.systemFont(ofSize: options.fontSize)
        textView.textContainer.lineFragmentPadding = 8
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textAlignment = .right
        textView.annotations = annotations

        // Determine the text color based on the current interface style
        let textColor: UIColor = context.environment.colorScheme == .dark ? .white : .black

        // Set the line spacing and alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = options.textAlignment.appleAlignment
        paragraphStyle.lineSpacing = 10

        // Ensure the text color and alignment are set in the attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: options.fontSize),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: textColor
        ]

        // Create a mutable attributed string to allow modifications
        let attributedString = NSMutableAttributedString(string: text.string, attributes: attributes)

        // Add annotations to the text
        for annotation in annotations {
            // Check if the range is valid
            if annotation.range.location + annotation.range.length <= attributedString.length {
                let backgroundColor = context.environment.colorScheme == .dark ? Constants.darkAnnotationColor : Constants.lightAnnotationColor
                attributedString.addAttribute(.backgroundColor, value: backgroundColor, range: annotation.range)
            }
        }

        textView.attributedText = attributedString

        return textView
    }

    func updateUIView(_ uiView: CustomTextView, context: Context) {
        // Determine the text color based on the current interface style
        let textColor: UIColor = context.environment.colorScheme == .dark ? .white : .black

        // Update the attributed text with line spacing and alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = options.textAlignment.appleAlignment
        paragraphStyle.lineSpacing = 10

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: options.fontSize),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: textColor
        ]

        // Create a mutable attributed string to allow modifications
        let attributedString = NSMutableAttributedString(string: text.string, attributes: attributes)
        uiView.attributedText = attributedString
        uiView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        // Add annotations to the text
        for annotation in annotations {
            // Check if the range is valid
            if annotation.range.location + annotation.range.length <= attributedString.length {
                let backgroundColor = context.environment.colorScheme == .dark ? Constants.darkAnnotationColor : Constants.lightAnnotationColor
                attributedString.addAttribute(.backgroundColor, value: backgroundColor, range: annotation.range)
            }
        }

        // Set the updated attributed text
        uiView.attributedText = attributedString
        uiView.annotations = annotations
    }
}
