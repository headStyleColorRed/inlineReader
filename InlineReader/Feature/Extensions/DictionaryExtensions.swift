//
//  DictionaryExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 25/10/21.
//  Copyright © 2024 airun. All rights reserved.
//

import Foundation

public extension Dictionary where Value: RangeReplaceableCollection {
    /// Appends an element to an array in a dictionary value, creating the array/value if needed

    mutating func append(element: Value.Iterator.Element, toValueOfKey key: Key) {
        var value: Value = self[key] ?? Value()
        value.append(element)
        self[key] = value
    }
}
