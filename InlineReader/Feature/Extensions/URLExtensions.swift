//
//  URLExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 28/3/22.
//  Copyright © 2022 airun. All rights reserved.
//

import UniformTypeIdentifiers
import Foundation

extension URL {
    public init?(string: String?) {
        guard let string = string else {
            return nil
        }

        self.init(string: string)
    }

    public var mimeType: String {
        guard let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType  else {
            return "application/octet-stream"
        }

        return mimeType
    }
}
