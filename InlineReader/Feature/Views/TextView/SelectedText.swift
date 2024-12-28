import Foundation

struct SelectedText: Identifiable {
    let id: UUID
    let text: String

    var lastSixtyWords: String {
        var splittedText = text.split(whereSeparator: { $0.isWhitespace })
            .filter { !$0.isEmpty }
            .prefix(60)
            .joined(separator: " ")
        splittedText.append("...")
        return splittedText
    }


    init(text: String) {
        self.id = UUID()
        self.text = text
    }
}
