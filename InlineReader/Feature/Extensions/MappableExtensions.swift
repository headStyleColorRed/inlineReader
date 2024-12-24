//
//  MappableExtensions.swift
//  
//
//  Created by Rodrigo Labrador Serrano on 21/9/22.
//

import ObjectMapper
import Foundation

public extension Mappable {
    /// Updates the object with the attributes of the argument. This can be useful instead of replacing the object when
    /// using with SwiftUI as this will trigger a redraw of the views observing the object.
    mutating func updateWith(_ newValue: Self) {
        self.mapping(map: Map(mappingType: .fromJSON, JSON: newValue.toJSON()))
    }

    /// Deep copies the object using ObjectMapper mappings
    func copy() -> Self? {
        return Self(JSON: self.toJSON())
    }
}

public extension Mapper {
    func map(JSON: [String: Any]?) -> N? {
        guard let JSON else { return nil }

        return map(JSON: JSON)
    }
}

public class ISODateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String

    public init() {}

    public func transformFromJSON(_ value: Any?) -> Object? {
        if let dateString = value as? String {
            return dateString.asDate
        }
        return nil
    }
    public func transformToJSON(_ value: Date?) -> JSON? {
        if let date = value {
            return date.asStringWith(locale: .utc)
        }
        return nil
    }
}

public class IntStringTransform: TransformType {
    public typealias Object = String
    public typealias JSON = Int

    public init() {}

    public func transformFromJSON(_ value: Any?) -> Object? {
        if let intValue = value as? Int {
            return intValue.description
        } else if let stringValue = value as? String {
            return stringValue
        }
        return nil
    }

    public func transformToJSON(_ value: String?) -> JSON? {
        if let value, let intValue = Int(value) {
            return intValue
        }
        return nil
    }
}
