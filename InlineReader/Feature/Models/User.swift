//
//  User.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 1/1/25.
//

import Foundation
import ObjectMapper

struct User: Mappable {
    var id: Int?
    var email: String?
    var role: UserRole?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        role <- map["role"]
    }
}

