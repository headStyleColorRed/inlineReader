import SwiftUI

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
