//
//  Session.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 1/1/25.
//

import SwiftUI

class Session: ObservableObject {
    static let shared = Session()

    var url: String = "http://192.168.1.78:3000"
}

