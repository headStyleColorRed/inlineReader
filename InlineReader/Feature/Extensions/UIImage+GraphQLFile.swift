//
//  UIImage+GraphQl.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 6/9/21.
//  Copyright © 2024 airun. All rights reserved.
//

import UIKit
import Apollo

public extension UIImage {
    func resizedImage(maxWidth: CGFloat = 480, maxHeight: CGFloat = 640) -> UIImage {
        let imageSize = self.size
        let widthRatio = maxWidth / imageSize.width
        let heightRatio = maxHeight / imageSize.height
        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)
        let rect = CGRect(origin: .zero, size: newSize)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage ?? self
    }

    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    func reduceQualityTo(_ jpegQuality: JPEGQuality) -> UIImage? {
        guard let data = self.jpegData(compressionQuality: jpegQuality.rawValue) else { return nil }
        return UIImage(data: data)
    }

    func asGraphQLFile(fieldName: String) -> GraphQLFile? {
        guard let imageURL = NSURL(fileURLWithPath:
                                    NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + ".jpg")
        else {
            return nil
        }
        guard (try? self.jpegData(compressionQuality: 0.7)?.write(to: imageURL)) != nil else {
            return nil
        }

        guard let file = try? GraphQLFile(fieldName: fieldName,
                                          originalName: "userProfile.jpg",
                                          mimeType: "image/jpeg",
                                          fileURL: imageURL) else {
            return nil
        }
        return file

    }
}
