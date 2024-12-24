//
//  ImageExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 18/5/21.
//  Copyright © 2024 airun. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    var withFixedOrientation: UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}
