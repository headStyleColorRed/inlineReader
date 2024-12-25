import SwiftUI


struct SelectableTextView: UIViewRepresentable {
    let text: String
    let options: Settings
    var onTextSelected: ((String) -> Void)?

    func makeUIView(context: Context) -> CustomTextView {
        let textView = CustomTextView(frame: .zero)
        textView.isEditable = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        textView.textColor = UIColor.white
        textView.onTextSelected = onTextSelected
        textView.font = UIFont.systemFont(ofSize: options.fontSize)
        textView.textContainer.lineFragmentPadding = 8
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textAlignment = .right

        // Set the line spacing and alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = options.textAlignment.appleAlignment
        paragraphStyle.lineSpacing = 10

        // Ensure the text color and alignment are set in the attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: options.fontSize),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        textView.attributedText = attributedString

        return textView
    }

    func updateUIView(_ uiView: CustomTextView, context: Context) {
        // Update the attributed text with line spacing and alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = options.textAlignment.appleAlignment
        paragraphStyle.lineSpacing = 10

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: options.fontSize),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.white
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        uiView.attributedText = attributedString
        uiView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}
