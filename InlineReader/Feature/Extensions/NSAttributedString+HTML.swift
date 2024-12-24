//
//  NSAttributedString+HTML.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 18/5/21.
//  Copyright © 2024 airun. All rights reserved.
//

import Foundation
import UIKit

public extension NSAttributedString {
    func simpleHTMLFragment() -> String {
        let mutable = NSMutableAttributedString(attributedString: self)

        mutable.enumerateAttributes(in: NSRange(0..<mutable.length), options: []) { attributes, range, _  in
            let attributedSubstring = mutable.attributedSubstring(from: range).string
            var htmlTaggedString = attributedSubstring

            if let font = attributes[.font] as? UIFont {
                htmlTaggedString = taggedString(htmlTaggedString, fromFont: font)
            }

            if let underlineStyle = attributes[.underlineStyle] as? Int {
                if underlineStyle != 0 {
                    htmlTaggedString = underline(htmlTaggedString, fromStyle: underlineStyle)
                }
            }

            mutable.replaceCharacters(in: range, with: htmlTaggedString)
        }

        var htmlFragment = mutable.string

        // Handle paragraphs
        // There is at least one paragraph that encompases the whole content
        htmlFragment = "<p>\(htmlFragment)</p>"
        // Replace line breaks by new paragraphs
        htmlFragment = htmlFragment.replacingOccurrences(of: "\n", with: "</p><p>")
        // Replace empty paragraphs by <br> tags
        htmlFragment = htmlFragment.replacingOccurrences(of: "<p></p>", with: "<br>")
        // Trim ending <br> tags
        while htmlFragment.hasSuffix("<br>") {
            let end = htmlFragment.index(htmlFragment.startIndex, offsetBy: htmlFragment.count - "<br>".count)
            htmlFragment = String(htmlFragment[..<end])
        }

        return htmlFragment
    }

    /// Returns the content string encapsulated in <strong> and/or <em> HTML tags, depending on the provided font.
    private func taggedString(_ content: String, fromFont font: UIFont) -> String {
        var taggedString = content

        if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
            taggedString = "<strong>\(taggedString)</strong>"
        }

        if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
            taggedString = "<em>\(taggedString)</em>"
        }

        return taggedString
    }

    /// Returns the content string encapsulated in an u HTML tag.
    private func underline(_ content: String, fromStyle style: Int) -> String {
        return "<u>\(content)</u>"
    }
}

public extension String {
    func convertHtml() -> NSMutableAttributedString {
        return attributedStringFromHTML ?? NSMutableAttributedString()
    }

    var attributedStringFromHTML: NSMutableAttributedString? {
        let text = "<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: 19\">\(self)</span>"
        guard let data = text.data(using: .utf8),
              let attributedString = try? NSMutableAttributedString(
                data: data,
                options: [.documentType: NSMutableAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil) else {
            return nil
        }

        // Remove trailing new line if exists
        if attributedString.string.hasSuffix("\n") {
            return NSMutableAttributedString(attributedString: attributedString.attributedSubstring(
                                                from: NSRange(location: 0, length: attributedString.length - 1))
            )
        } else {
            return attributedString
        }
    }
}
