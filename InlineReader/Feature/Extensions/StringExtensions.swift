//
//  StringExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 18/5/21.
//  Copyright © 2024 airun. All rights reserved.
//

import Foundation
import SwiftUI

public extension String {
    var asDate: Date? {
        if let date = dateWith(format: .ISO8601) {
            return date
        } else if let date = dateWith(format: .ISO8601Z) {
            return date
        } else if let date = dateWith(format: .ISO8601WithMilliseconds) {
            return date
        } else if let date = dateWith(format: .ISO8601OnlyDate) {
            return date
        }

        return nil
    }

    // Returns a new Date with the time at 00:00 in the current timezone and the same day included in a ISO8601 String.
    // For example: "2022-05-26T00:00:00+02:00" would return a date of ""2022-05-26T00:00:00" in the current timezone.
    var asDateWithoutTime: Date? {
        let capturePattern = #"(?<year>\d{1,4})-(?<month>\d{1,2})-(?<day>\d{1,2})"#

        guard let regex = try? NSRegularExpression(pattern: capturePattern, options: []),
              let match = regex.firstMatch(in: self,
                                           options: [],
                                           range: NSRange(startIndex ..< endIndex, in: self)) else { return nil }

        var captures: [String: String] = [:]

        for name in ["month", "day", "year"] {
            let matchRange = match.range(withName: name)

            if let substringRange = Range(matchRange, in: self) {
                let capture = String(self[substringRange])
                captures[name] = capture
            }
        }

        guard let yearString = captures["year"], let year = Int(yearString),
              let monthString = captures["month"], let month = Int(monthString),
              let dayString = captures["day"], let day = Int(dayString) else { return nil }

        let dateComponents = DateComponents(calendar: .current,
                                            timeZone: TimeZone(identifier: "UTC")!,
                                            year: year,
                                            month: month,
                                            day: day)

        return Calendar.current.date(from: dateComponents)
    }

    func dateWith(format: DateFormats, timeZone: TimeZone? = nil) -> Date? {
        if format == .ISO8601 {
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: self)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let timeZone = timeZone {
            dateFormatter.timeZone = timeZone
        } else {
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        }
        dateFormatter.dateFormat = format.formatted

        return dateFormatter.date(from: self)
    }

    /// Returns the string as a generic error with no domain or code.
    /// Just the string's value as .localizedDescription
    var asError: Error {
        return NSError(domain: "", code: -1,
                       userInfo: [NSLocalizedDescriptionKey: self])
    }

    var humanized: String {
        // Capitalize first letter
        let capitalized = self.prefix(1).capitalized + dropFirst()

        // Humanize snake_case
        let humanized = capitalized.replacingOccurrences(of: "_", with: " ")

        return humanized
    }

    /// When passed a regular expression it returns an `isValid` of type boolean
    func matchesRegex(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }

    /// Returns a new string with all empty lines removed
    var withEmptyLinesStripped: String {
        replacingOccurrences(of: "\\n{2,}", with: "\n", options: .regularExpression)
    }

    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return self.processCamalCaseRegex(pattern: acronymPattern)?
            .processCamalCaseRegex(pattern: normalPattern)?.lowercased() ?? self.lowercased()
    }

    private func processCamalCaseRegex(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

public extension Optional where Wrapped == String {
    var asInt: Int? {
        guard let string = self else { return nil }
        return Int(string)
    }
}

public extension Int {
    var asString: String {
        return String(self)
    }

    var ordinal: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal

        return formatter.string(from: NSNumber(value: self))
    }
}

public extension Optional where Wrapped == Int {
    var asString: String? {
        guard let int = self else { return nil }
        return String(int)
    }
}

public extension String {
    func htmlToAttributedString(fontSize: CGFloat = 14,
                                color: Color = Color(hex: "#3B3B3B"),
                                linkColor: Color = .airunBlue) -> AttributedString? {
        if #available(iOS 16.0, *) {
            guard let data = data(using: .utf8),
                  let nsAttributedString = try? NSMutableAttributedString(data: data, options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                  ], documentAttributes: nil) else { return nil }

            let range = NSRange(location: 0, length: nsAttributedString.length)
            nsAttributedString.enumerateAttribute(NSAttributedString.Key.font,
                                                  in: range,
                                                  options: .longestEffectiveRangeNotRequired) { value, range, _ in
                guard let currentFont = value as? UIFont else { return }
                let fontName = currentFont.fontName.lowercased()

                let replacementFont: UIFont = switch fontName {
                case let name where name.contains("bolditalic"):
                        .systemFont(ofSize: fontSize, weight: .semibold)
                case let name where name.contains("bold"):
                        .systemFont(ofSize: fontSize, weight: .semibold)
                case let name where name.contains("italic"):
                        .systemFont(ofSize: fontSize)
                default:
                        .systemFont(ofSize: fontSize)
                }

                let replacementAttribute = [NSAttributedString.Key.font: replacementFont]
                nsAttributedString.addAttributes(replacementAttribute, range: range)
            }

            var attributedString = AttributedString(nsAttributedString)
            attributedString.foregroundColor = color

            // Links
            let types: NSTextCheckingResult.CheckingType = [.link]
            if let linkDetector = try? NSDataDetector(types: types.rawValue) {
                let linkMatches = linkDetector.matches(in: nsAttributedString.string,
                                                       options: [],
                                                       range: NSRange(location: 0, length: nsAttributedString.length))

                linkMatches.forEach {
                    guard let range = Range($0.range, in: attributedString),
                          let stringRange = Range($0.range, in: nsAttributedString.string),
                          let url = URL(string: String(nsAttributedString.string[stringRange])) else { return }

                    var attributeContainer = AttributeContainer()
                    attributeContainer.underlineStyle = .single
                    attributeContainer.foregroundColor = linkColor
                    attributeContainer.link = url

                    attributedString[range].mergeAttributes(attributeContainer)
                }
            }

            return attributedString
        } else {
            return (try? AttributedString(markdown: htmlToMarkDown())) ?? AttributedString(stringLiteral: self)
        }
    }

    func htmlToMarkDown() -> String {
        var text = self

        // Text formatting
        text = text.replaceTag("b", with: "**")
        text = text.replaceTag("i", with: "_")
        text = text.replacingOccurrences(of: "<p>", with: "")
        text = text.replacingOccurrences(of: "</p>", with: " ")
        text = text.replacingOccurrences(of: "<br>", with: " ")
        text = text.replaceTag("strong", with: "**")
        text = text.replaceTag("em", with: "_")
        text = text.replaceTag("u", with: "")

        return text
    }

    private func replaceTag(_ tag: String, with replacement: String) -> String {
        let firstReplacement = replaceTagWithText(input: self, tag: "<\(tag)>", replacement: replacement)
        let secondReplacement = replaceCloseTagWithText(input: firstReplacement,
                                                        tag: "</\(tag)>",
                                                        replacement: replacement)
        return secondReplacement
    }

    private func replaceTagWithText(input: String, tag: String, replacement: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "\(tag)(\\s*)", options: [])
            let range = NSRange(location: 0, length: input.utf16.count)

            if let match = regex.firstMatch(in: input, options: [], range: range) {
                let spacesRange = match.range(at: 1)
                let spaces = (input as NSString).substring(with: spacesRange)
                let replacedText = "\(spaces)\(replacement)"

                return regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: replacedText)
            }
        } catch {
            print("Error creating regex: \(error)")
        }

        return input
    }

    private func replaceCloseTagWithText(input: String, tag: String, replacement: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: "(\\s*)\(tag)", options: [])
            let range = NSRange(location: 0, length: input.utf16.count)

            if let match = regex.firstMatch(in: input, options: [], range: range) {
                let spacesRange = match.range(at: 1)
                let spaces = (input as NSString).substring(with: spacesRange)
                let replacedText = "\(replacement)\(spaces)"

                return regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: replacedText)
            }
        } catch {
            print("Error creating regex: \(error)")
        }

        return input
    }
}

// https://stackoverflow.com/a/39425959
public extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

public extension String {
    var isSingleEmoji: Bool { count == 1 && containsEmoji }

    var containsEmoji: Bool { contains { $0.isEmoji } }

    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }

    var emojiString: String { emojis.map { String($0) }.reduce("", +) }

    var emojis: [Character] { filter { $0.isEmoji } }

    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
}
