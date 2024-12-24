//
//  FontExtension.swift
//  TestingSwiftUI
//
//  Created by Rodrigo Labrador Serrano on 9/11/24.
//

import SwiftUI

extension Font.Weight {
    static func custom(_ weight: CGFloat) -> Font.Weight {
        switch weight {
        case ..<150:
            return .ultraLight
        case 150..<250:
            return .thin
        case 250..<350:
            return .light
        case 350..<450:
            return .regular
        case 450..<550:
            return .medium
        case 550..<650:
            return .semibold
        case 650..<750:
            return .bold
        case 750..<850:
            return .heavy
        case 850...:
            return .black
        default:
            return .regular
        }
    }
}

