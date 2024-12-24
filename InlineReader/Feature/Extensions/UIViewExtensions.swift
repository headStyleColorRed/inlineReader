//
//  UIViewExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 18/5/21.
//  Copyright © 2024 airun. All rights reserved.
//

import UIKit

public extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}

public extension UIView.AnimationOptions {
    init(curve: UIView.AnimationCurve) {
        switch curve {
        case .easeIn:
            self = [.curveEaseIn]
        case .easeOut:
            self = [.curveEaseOut]
        case .easeInOut:
            self = [.curveEaseInOut]
        case .linear:
            self = [.curveLinear]
        @unknown default:
            self = [.curveLinear]
        }
    }
}
