//
//  CollectionExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 10/12/21.
//  Copyright © 2024 airun. All rights reserved.
//

import Foundation

public extension RangeReplaceableCollection where Element: Equatable, Index == Int {
    /// Appends an element at the end of the array only if doesn't exist already
    mutating func appendIfNotContains(_ element: Element) {
        guard firstIndex(of: element) == nil else { return }
        append(element)
    }

    /// Inserts an element at the chosen index in an array only if doesn't exist already
    mutating func insertIfNotContains(_ element: Element, at index: Int) {
        guard firstIndex(of: element) == nil else { return }
        insert(element, at: index)
    }

    /// Appends an element to the array only if is a non-nil value
    mutating func appendUnwrappedElement(_ element: Element?) {
        guard let element = element else { return }
        append(element)
    }
}
