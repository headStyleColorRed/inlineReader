//
//  UIContextualActionExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 17/1/22.
//  Copyright © 2022 airun. All rights reserved.
//

import Foundation
import UIKit

public extension UIContextualAction {
    /// Generates an image containing both a text title and and image to use in a contextual action. By default iOS only
    /// shows title and image together if the cell is over 91 points height. This circumvents that limitation by
    /// generating an image that already includes the title
    static func generateImageWithTitle(forCellWithHeight cellHeight: CGFloat = 91,
                                       image: UIImage,
                                       title: String) -> UIImage? {
        let mask = image.withRenderingMode(.alwaysTemplate)
        let stockSize = String(repeating: " ", count: 8).size(
            withAttributes: [.font: UIFont.systemFont(ofSize: 18)])
        let height = cellHeight
        let width = max(stockSize.width + 30,
                        title.size(withAttributes: [.font: UIFont.systemFont(ofSize: 18)]).width + 10)
        let actionSize = CGSize(width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(actionSize, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            context.clear(CGRect(origin: .zero, size: actionSize))
        }

        UIColor.white.set()

        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white,
                                                         .font: UIFont.systemFont(ofSize: 18)]
        let textSize = title.size(withAttributes: attributes)
        let textPoint = CGPoint(x: (width - textSize.width) / 2,
                                y: (height - (textSize.height * 3)) / 2 + (textSize.height * 2))

        title.draw(at: textPoint, withAttributes: attributes)
        let maskHeight = textSize.height * 1.5
        let maskWidth = image.size.width * maskHeight / image.size.height
        let maskRect = CGRect(x: (width - maskWidth) / 2,
                              y: textPoint.y - maskHeight,
                              width: maskWidth,
                              height: maskHeight)
        mask.draw(in: maskRect)

        var actionImage: UIImage?
        if let result = UIGraphicsGetImageFromCurrentImageContext() {
            actionImage = result
        }
        UIGraphicsEndImageContext()

        return actionImage
    }
}
