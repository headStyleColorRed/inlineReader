//
//  ChatResponse.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 28/12/24.
//

import Foundation

struct ChatResponse: Codable {
    let id: String
    let object: String
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
            let refusal: String?
        }
        let message: Message
        let finish_reason: String
    }
    let choices: [Choice]
    }
