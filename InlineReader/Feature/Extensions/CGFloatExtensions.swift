//
//  CGFloatExtensions.swift
//
//
//  Created by Rodrigo Labrador Serrano on 21/11/23.
//

import Foundation

public extension CGFloat {
    func isEqual(to other: CGFloat, withTolerance tolerance: CGFloat = 0) -> Bool {
        return abs(self - other) <= tolerance
    }
}
