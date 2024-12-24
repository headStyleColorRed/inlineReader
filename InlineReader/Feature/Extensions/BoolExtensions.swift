//
//  BoolExtensions.swift
//  
//
//  Created by Rodrigo Labrador Serrano on 14/9/22.
//

import Foundation
import SwiftUI

public extension Optional where Wrapped == Bool {
    static prefix func !(value: Bool?) -> Bool? {
        guard let value = value else { return nil }

        return !value
    }

    static prefix func !(value: Bool?) -> Bool {
        guard let value = value else { return false }

        return !value
    }
}

public extension Binding {
    func presence<T>() -> Binding<Bool> where Value == T? {
        return .init {
            self.wrappedValue != nil
        } set: { newValue in
            precondition(newValue == false)
            self.wrappedValue = nil
        }
    }
}
