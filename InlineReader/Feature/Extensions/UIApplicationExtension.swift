//
//  UIApplicationExtension.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 20/10/21.
//  Copyright © 2024 airun. All rights reserved.
//

import SwiftUI

extension UIApplication: UIGestureRecognizerDelegate {
    public func addKeyboardAwareness() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}
