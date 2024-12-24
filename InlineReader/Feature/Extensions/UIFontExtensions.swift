//
//  UIFontExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 20/9/21.
//  Copyright © 2024 airun. All rights reserved.
//

import UIKit

public extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return self
        }

        return UIFont(descriptor: descriptor, size: pointSize)
    }

    func italics() -> UIFont {
        return withTraits(.traitItalic)
    }

    func bold() -> UIFont {
        return withTraits(.traitBold)
    }
}
