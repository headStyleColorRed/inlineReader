//
//  UIImage+Base64.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 20/9/21.
//  Copyright © 2024 airun. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    var base64PNG: String? {
        var result = self.pngData()?.base64EncodedString()
        if let base64 = result {
            result = "data:image/png;base64,\(base64)"
        }

        return result
    }
}
