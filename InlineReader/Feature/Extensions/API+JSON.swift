//
//  API+JSON.swift
//  airun-ios
//
//  Created by Rodrigo Labrador Serrano on 19/12/24.
//

import Foundation
import ApolloAPI
import ObjectMapper

extension JSONValue: Encodable {
    struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        init?(stringValue: String) { self.stringValue = stringValue }
    }

    public func encode(to encoder: Encoder) throws {
        if let array = self as? [any Hashable] {
            var container = encoder.unkeyedContainer()
            for value in array {
                let val = JSONValue(value)
                try container.encode(val)
            }
        } else if let dictionary = self as? [String: any Hashable] {
            var container = encoder.container(keyedBy: CodingKeys.self)
            for (key, value) in dictionary {
                let codingKey = CodingKeys(stringValue: key)!
                let val = JSONValue(value)
                try container.encode(val, forKey: codingKey)
            }
        } else {
            var container = encoder.singleValueContainer()
            if let intVal = self as? Int {
                try container.encode(intVal)
            } else if let doubleVal = self as? Double {
                try container.encode(doubleVal)
            } else if let boolVal = self as? Bool {
                try container.encode(boolVal)
            } else if let stringVal = self as? String {
                try container.encode(stringVal)
            } else {
                throw EncodingError.invalidValue(self, .init(codingPath: [],
                                                             debugDescription: "The value is not encodable"))
            }
        }
    }
}

extension DataDict {
    func convertToJSON() -> [String: AnyHashable] {
        _data.mapValues {
            switch $0 {
            case let customScalar as CustomScalarType:
                return customScalar._jsonValue
            case let nestedEntity as DataDict:
                return nestedEntity.convertToJSON()
            case let arrayOfNestedEntity as [DataDict]:
                let nestedMap = arrayOfNestedEntity.map { dataDict in
                    return dataDict.convertToJSON()
                }
                return nestedMap
            default:
                return $0
            }
        }
    }
}

extension SelectionSet {
    public var json: JSONObject {
        return __data.convertToJSON()
    }

    /// This method will return a mapped object of an apollo element response
    /// You'll need to pass the Object type you want to map
    /// ```
    /// return result.data?.airun?.dynamicAppointments?.appointment?.mapped(Appointment.self)
    /// ```
    public func mapped<T: Mappable>(_ type: T.Type) -> T? {
        return Mapper<T>().map(JSON: self.json)
    }
}

extension Array where Element: SelectionSet {
    /// This method will return a mapped array of an apollo array response
    /// Given an array of nodes, you'll need to pass the Object type you want to map
    /// ```
    /// return result.data?.airun?.dynamicAppointments?.appointments?.nodes?.mapped(Appointment.self)
    /// ```
    public func mapped<T: Mappable>(_ type: T.Type) -> [T] {
        return compactMap { Mapper<T>().map(JSON: $0.json) }
    }
}

// This protocol and extensions are needed because Swift currently lacks a way to make an extension to an Array of
// optionals which Wrapped value should implement a protocol. There are two Swift Evolution proposal that could make
// this possible: Parameterized Extensions and Generic Where clauses. Until then, this protocol extension dance would
// do. Note that in this case we need to cast as `any SelectionSet` as we lose the actual type when using the
// OptionalSelectionSet protocol.

public protocol OptionalSelectionSet {}
extension Optional: OptionalSelectionSet where Wrapped: SelectionSet {}

public extension Array where Element: OptionalSelectionSet {
    /// This method will return a mapped array of an apollo array response
    /// Given an array of nodes, you'll need to pass the Object type you want to map
    /// ```
    /// return result.data?.airun?.dynamicAppointments?.appointments?.nodes?.mapped(Appointment.self)
    /// ```
    func mapped<T: Mappable>(_ type: T.Type) -> [T] {
        return compactMap { Mapper<T>().map(JSON: ($0 as? any SelectionSet)?.json) }
    }
}

