//
//  File.swift
//  
//
//  Created by Rodrigo Labrador Serrano on 22/12/22.
//

import Foundation
import UIKit

public extension UIImage {
    private func getDocumentDirectoryPath() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }

    var getTempURL: URL? {
        if let data = self.pngData() {
            let dirPath = getDocumentDirectoryPath()
            let imageFileUrl = URL(fileURLWithPath: dirPath.appendingPathComponent(UUID().uuidString) as String)
            do {
                try data.write(to: imageFileUrl)
                return imageFileUrl
            } catch {
                print("There was an error processing the image")
            }
        }
        return nil
    }

    var withCorrectOrientation: UIImage {
        guard let cgImage = self.cgImage else { return self }

        let orientation = self.imageOrientation
        guard orientation != .up else { return UIImage(cgImage: cgImage, scale: 1, orientation: .up) }

        var transform = CGAffineTransform.identity

        if orientation == .down || orientation == .downMirrored {
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        } else if orientation == .left || orientation == .leftMirrored {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        } else if orientation == .right || orientation == .rightMirrored {
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -(CGFloat.pi / 2))
        }

        if orientation == .upMirrored || orientation == .downMirrored {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        } else if orientation == .leftMirrored || orientation == .rightMirrored {
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }

        // Now we draw the underlying CGImage into a new context, applying the transform calculated above.
        guard let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                  bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0,
                                  space: cgImage.colorSpace!, bitmapInfo: cgImage.bitmapInfo.rawValue) else {
            return UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
        }

        ctx.concatenate(transform)

        // Create a new UIImage from the drawing context
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }

        return UIImage(cgImage: ctx.makeImage() ?? cgImage, scale: 1, orientation: .up)

    }

}

public extension UIImage {
    // This functions generates a UIImage with a gray background and a big bold letter on top intended to be used as a
    // placeholder avatar
    static func placeHolderImage(with letter: String) -> UIImage {
        let initial = String(letter.first!)

        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)

        let renderer = UIGraphicsImageRenderer(bounds: rect)
        let image = renderer.image { context in
            // Draw gray background
            context.cgContext.setFillColor(UIColor.gray.cgColor)
            context.cgContext.fill(rect)

            // Set up attributes for the text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 56).bold(),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]

            // Calculate the rectangle for the text
            let textSize = initial.size(withAttributes: attributes)
            let textRect = CGRect(x: (rect.size.width - textSize.width) / 2.0,
                                  y: (rect.size.height - textSize.height) / 2.0,
                                  width: textSize.width,
                                  height: textSize.height)

            // Draw the text
            initial.draw(in: textRect, withAttributes: attributes)
        }

        return image
    }
}
