//
//  ColorExtensions.swift
//  airun-ios
//
//  Created by Rodrigo Labrador Serrano on 19/12/24.
//

import SwiftUI

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }

    var hexString: String? {
        guard let components = cgColor?.components, components.count >= 3 else {
            return nil
        }

        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        let alpha = Float(components.count > 3 ? components[3] : 1)

        if alpha != 1 {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(red * 255),
                          lroundf(green * 255),
                          lroundf(blue * 255),
                          lroundf(alpha * 255))
        }
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(red * 255),
                      lroundf(green * 255),
                      lroundf(blue * 255))
    }
}

extension Color {
    static var main: Color { return Color(hex: "#222831") }
    static var secondary: Color { return Color(hex: "#31363F") }
    static var details: Color { return Color(hex: "#76ABAE") }
    static var whites: Color { return Color(hex: "#EEEEEE") }
}
