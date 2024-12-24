//
//  NSErrorExtensions.swift
//  airun-ios
//
//  Created by Rodrigo Labrador Serrano on 19/12/24.
//

import Foundation

extension NSError {
    static var parsingError: Error {
        return "Failed to map model".asError
    }

    static var networkError: Error {
        return "Status code not in 200-299".asError
    }

    static var unknownError: Error {
        return "Unknown error".asError
    }
}
